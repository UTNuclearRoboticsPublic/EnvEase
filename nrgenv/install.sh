cd "$(dirname "${BASH_SOURCE[0]}")"

sudo apt install python3-pip
python3 -m pip install -q pipreqs
pipreqs --force .
sudo python3 -m pip install -r ./requirements.txt

sudo cp nrgenv.py /bin/nrgenv
rm requirements.txt