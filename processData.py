# this file process the data files into the regular csv file
import csv
import pdb
inputfile = 'data.draftkings.scsv'
outputfile = 'data.draftkings.formatted.scsv'

playerDict = {}

class Player():
    def __init__(self, name, team, pos):
        self.name = name
        self.team = team
        self.pos = pos
        self.history = []

class Stat():
    def __init__(self, date, salary, fantasypoint, stats, minute):
        self.date = date
        self.salary = salary
        self.fantasypoint = fantasypoint
        self.statline = stats
        self.minute = minute

    def __str__(self):
        return '{0} {1} {2}'.format(self.salary, self.fantasypoint, self.statline)

with open(inputfile, 'r') as csvinput:
    reader = csv.reader(csvinput, delimiter=';')
    reader.next() # remove the header
    dates = []
    for row in reader:
        [date, gid, pos, name, starter, fantasypoint, salary, team, homeaway, oppt, teamscore,\
                opptscore, minute, stats] = row

        fantasypoint = float(fantasypoint)
        stat = Stat(date, salary, fantasypoint, stats, minute)
        if name in playerDict:
            p = playerDict[name]
        else:
            p = Player(name, team, pos)
            playerDict[name] = p
        p.history.append(stat)
        dates.append(date)

dates = sorted(list(set(dates)))

# outputing to the new csv
with open(outputfile, 'w') as csvoutput:
    writer = csv.writer(csvoutput, delimiter=';')
    for name in playerDict:
        p = playerDict[name]
        playerinfo = [p.name, p.team, p.pos]
        playerhistory = []
        for d in dates:
            hist = filter(lambda h:h.date==d, p.history)
            if hist:
                hist = hist[0]
                if hist.minute == 'NA' or hist.minute == 'DNP':
                    playerhistory += ['NaN', 'NaN', 'NaN']
                else:
                    playerhistory += [hist.salary, hist.fantasypoint, hist.minute]
            else:
                playerhistory += ['NaN', 'NaN', 'NaN']
        row = playerinfo + playerhistory
        print(len(row))
        writer.writerow(row)

