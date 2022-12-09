cd "$(dirname "${BASH_SOURCE[0]}")"

pip install -q pipreqs
pipreqs --force .
pip install -r ./requirements.txt

cp nrgenv.py /bin/nrgenv
rm requirements.txt