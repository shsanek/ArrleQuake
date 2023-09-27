if [ -d "ArrleQuake" ]; then
    cd ArrleQuake
    git checkout
    git remote update
    git pull

else
    git clone git@github.com:shsanek/ArrleQuake.git
    cd ArrleQuake
fi

cd ArrleQuakeCore

screen -d -m ./build.sh TOKEN CHAT Resource TMP 
