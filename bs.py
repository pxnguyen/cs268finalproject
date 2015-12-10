from bs4 import BeautifulSoup
import requests 

def getData(month, day, file):

	r = requests.get("http://rotoguru1.com/cgi-bin/hyday.pl?mon=" + str(month) + "&day=" + str(day) + "&year=2015&game=dk&scsv=1")
	soup = BeautifulSoup(r.text)

	data = soup.pre.string.split("\n")
	for line in data[1:-1]:
		file.write(line + "\n")

outputfile = 'data.draftkings.scsv'
with open(outputfile, 'w') as file:
	for i in (range(1, 31)):
		getData(11, i, file)
	for i in (range(1, 9)):
		getData(12, i, file)

