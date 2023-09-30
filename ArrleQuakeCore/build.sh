TELEGRAM_BOT_TOKEN=$1
TELEGRAM_BOT_CHAT=$2
BUILD_TYPE="debug"

echo "
#define SERVER_ONLY 1
" > "Sources/ArrleQuakeC/id1/DEFINE.h"

sendMessage () {
    local text="$1"
    curl -X POST \
        -H 'Content-Type: application/json' \
        -d "{\"chat_id\": \"${TELEGRAM_BOT_CHAT}\", \"text\": \"${text}\"}" \
        https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage
}

sendFile () {
    sendMessage "$1"
    curl -F document=@"$2" https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendDocument?chat_id=$TELEGRAM_BOT_CHAT
}

sendMessage "Начинаем сборку проэкта в ${BUILD_TYPE} режиме (в релизном занимает до 15 минут)."
fileLog="../../log/$(date +"%Y_%m_%d_%I_%M_%p").log"
swift package update
swift build -c $BUILD_TYPE --product ArrleQuakeServer 2>&1 | tee $fileLog

if grep -q "Build complete!" "$fileLog"; then
    sendFile "Cборка прошла успешно ${output}" $fileLog
else
    sendFile "Во время сборки что то пошло не так исполнение не будет продолжено" $fileLog
    exit 1
fi

sendMessage "Копируем в исполняемую категорию. Останваливаем старый проект перезапускаем прокси, запускаем демона"
COUNTER = 7
while [  "$COUNTER" -gt 0 ]; do
    sudo kill -9 `sudo lsof -t -i:26000`
    COUNTER=$((COUNTER-1))
    sleep 2
done
sudo kill -9 `sudo lsof -t -i:26000`
sendMessage "Стопанулось?"

scp .build/$BUILD_TYPE/ArrleQuakeServer ../../run/$BUILD_TYPE/server

tryes=10

while [ "$ARRLE_STOP" != "STOP" ] && [ "$tryes" -gt 0 ]; do
    sendMessage "Цикл демона. Осталось попыток: ${tryes}\"}"

    tryes=$((tryes-1))

    fileLog="../../log/$(date +"%Y_%m_%d_%I_%M_%p").log"

    sleep 5

    ../../run/$BUILD_TYPE/server $PWD/../../$3 $PWD/../../$4 2>&1 | tee $fileLog

    sudo kill -9 `sudo lsof -t -i:26000`

    sendFile "Сервер упал" $fileLog
done

if [ $ARRLE_STOP != "STOP" ]; then
    sendMessage "Попытки закончились перезагрузите сервер в ручную"
else
    sendMessage "Ручная остановка сервера"
fi

