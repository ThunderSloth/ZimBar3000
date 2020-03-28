function voyage_get_regex()
	return {
        vision = rex.new("([Tt]he limit of your vision is .+? from here(?: and)?[,.]?)"),
        doors = rex.new("((?:[Aa] )?[Dd]oors?.*?of (?:[1-5]? ?(?:(?(?=starboard|port)(starboard|port)(aft|fore)?|(aft|fore)))|and|,|here| )+)"),
        exits = rex.new("((?:[Aa]n? (?:hard to see through )?)?[Ee]xits?.*?of (?:[1-5]? ?(?:(?(?=starboard|port)(starboard|port)(aft|fore)?|(aft|fore)))|(?:and|,|here| ))+)"),
        population = rex.new("([^ ].+?(?: is | are )(?:[1-5]? ?(?:(?(?=starboard|port)(starboard|port)(aft|fore)?|(aft|fore)))|and|,| )+)"),
        directions = rex.new("((?(?=starboard|port)(starboard|port)(aft|fore)?|(aft|fore)))"),
        door_and_exit_directions = rex.new("((?(?=starboard|port)(starboard|port)(aft|fore)?|(aft|fore)))(?=.* of )"),
        door_and_exit_paths = rex.new("((?(?=starboard|port)(starboard|port)(aft|fore)?|(aft|fore)))(?!.* of )"),
        hull_report = rex.new("^(?! needs? .*).* (repair|fixed|max).*$"),
        other_report = rex.new("^.*(got the|gone|no more|off|clear).*$"),
        adjacent_fire = rex.new("^.* firelight can be seen to ((((?(?=starboard|port)(starboard|port)( aft| fore)?|(aft|fore)))((, | and ))?)+).*$"),
        sleeping = rex.new("^(?:.* (?:is|are) .*?(?:, | and ))?(.*) (?:is|are) (sleeping|knocked out) here.*$"),
        circle = rex.new("^(?:.* (?:is|are) .*?(?:, | and ))?(.*) (?:is|are) sitting in the small red circle.*$"),
        titles = rex.new(
-- TITLE REGEX:
[[(?(DEFINE)
(?# GUILDS: )
(?'assassins'(d(octo)?r|professor))
(?'priests'((?(?=blessed|venerable|holy)(blessed|venerable|holy)( (brother|sister|father|mother))?|(brother|sister|father|mother))|(mostly )?reverend|blessed|beatus|saint|high priest(ess)?|(his|her|it'?s) eminence|minister|outcast))
(?'thieves'(crafty|crooked|dastardly|dishonest|dodgy|elusive|evasive|furtive|greased|honest|latent|((light|quick)[-]|butter)?finger(ed|s)|quiet|shady|shifty|silent|slick|sly|tricky))
(?'witches'(?# duplicates: mother, old, mistress, sister)((?# goodie, goody)good(y|ie)|gammer|gra(mma|nny)|(?# mss, mee)m[se]{2}|(?# nanny, nanna)nann[ay]|aunty|biddy|black|mama|wee|wicked|young))
(?'wizards'(fat|stuffed|overfed|gimlet[-]eyed|robust|bearded|burly|plump|rotund|thin|tiny|mystic|obscure|complex|learned|potent|wise|grumpy|cryptic|dark|scholarly|grey[-]?(haired|beard)|adroit|dire|maven|quantum|savant|unseen|(arch)?(master|mistress|mage)))
(?# COUNCIL: )
(?'council_am'(dame|lady|lord|sir)) 
(?'court_positive'the (amazing|civic[-]minded|elegant|eloquent|(helpful|upstanding(?= citizen))( citizen)?|stylish|utterly fluffy|wonderful))
(?'court_punishment'(appallingly filthy|corpse looter|dull|feebleminded|i (promise i won't do it again|got punished( and all i got was this lousy title)?)|insignificant|lying|malingering|naughty spawn|necrokleptomaniac|offensive|pillock|pointless|repentant|reprobate|shopkeeper murderer|silly spammy git|sitting in the corner|smelly|tantrum thrower|too stupid to live|vagrant|(very ){1,2}sorry|waste of space|whinging))
(?'council_djb'(?# duplicates: feebleminded, corpse looter, cowardly)(sultana?|(shai|sitt) (al[-](khasa|ri'asa)|ishqu?araya|a'daha)|nawab|qasar|mazrat|effendi|ya'uq|mutasharid|ishqu?araya|naughty spawn|kill stealer|idiotic|offensive|corpse looter|cat hating|heathen|foreign dog|infidel|shopkeeper murderer|destitute|parasitic|hated|cowardly|criminal|felon))
(?# ACHIEVEMENTS: )
(?'achievements_thieves'(ruinous|fingers))
(?'achievements_warriors'(centurion|chef|head(master|mistress)|impaler|pulveriser))
(?'achievements_witches'(destined|nasty|terrible))
(?'achievements_fools'pious)
(?'achievements_wizards'(erratic mechanic|mysterious|arcana))
(?'achievements_priests'(templar|healer|saintly))
(?'achievements_assassins'(lethal|venomous))
(?'achievements_all'(?# axe-master, shieldmaster/mistress, staffmaster/mistress)((sword|shield|staff|axe[-])(master|mistress)|antiquated|archaic|old( (wo)?man)?|bloodthirsty|bruiser|champion|competent|contender|crimewave|crusher|cultured|cutthroat|deckhand|decrepit|diplomatic|duelist|elementalist|energetic|exterminator|festive|filthy|flatulent|fossilized|gifted|golden|knifey|legendary|literate|masterful|medical|miner|multilingual|[nm]urse|mythical|nimble|obsolete|opulent|paranoid|perverse|prehistoric|rock[-]hard|rouge|senile|captain|stormrider|unburiable|unexpected|unlucky|unstoppable|venerable|versatile|virtuoso|wealthy))
(?'quest_points'(well travelled|persistent))
(?# MISC: )
(?'general'm([sx]|rs?|iss))
(?'genua'(?# m, monsieur, mlle, mademoiselle, mme, madame)m(?=(\Z|$| |me|lle|onsieur|adame|ademoiselle))(me|lle|onsieur|adame|ademoiselle)?)
(?'ghosts'(lonely|mournful|scary|spooky|wandering))
(?'musketeers'(cheating|cowardly))
(?'debaters'(diplomatic|uncreative)))(?#
 TITLE REGEX: 
)^(?<title>(?P>assassins)|(?P>priests)|(?P>thieves)|(?P>witches)|(?P>wizards)|(?P>council_am)|(?P>court_positive)|(?P>court_punishment)|(?P>council_djb)|(?P>achievements_thieves)|(?P>achievements_warriors)|(?P>achievements_witches)|(?P>achievements_fools)|(?P>achievements_wizards)|(?P>achievements_priests)|(?P>achievements_assassins)|(?P>achievements_all)|(?P>quest_points)|(?P>general)|(?P>genua)|(?P>ghosts)|(?P>musketeers)|(?P>debaters)) ]]),
}
end
--[[
TITLES TESTING:

GENERAL
miss
mr
mrs
ms
mx
GHOSTS
lonely
mournful
scary
spooky
wandering
MUSKATEERS
cheating
cowardly
ASSASSINS
doctor
dr
professor
PRIESTS
brother
sister
mostly reverend
reverend 
blessed 
blessed father  
blessed mother 
blessed brother  
blessed sister 
venerable 
venerable brother  
venerable sister 
venerable father  
venerable mother 
holy 
holy brother  
holy sister 
beatus 
saint 
high priest
high priestess
his eminence
her eminence
it's eminence
its eminence
minister
THIEVES
butterfingers
crafty
crooked
dastardly
dishonest
dodgy
elusive
evasive
fingers
furtive
greased
honest
latent
light-fingered
quick-fingered
quiet
shady
shifty
silent
slick
sly
tricky
WITCHES
aunty
biddy
black
gammer
goodie
goody
gramma
granny
mama
mistress
mother
mss
nanna
nanny
old
sister
wee
wicked
young
WIZARDS
fat
stuffed
overfed
gimlet-eyed
robust
bearded
burly
plump
rotund
thin
tiny
mystic
obscure 
complex
learned 
potent
wise
grumpy 
cryptic
dark
scholarly
grey-haired
greybeard
master
mistress 
adroit
dire
maven 
quantum
savant
unseen 
archmaster
mistress
archmage 
COUNCIL AM
dame 
lady 
lord 
sir 
COURT: POSITIVE
the amazing
the civic-minded
the elegant
the eloquent
the helpful
the helpful citizen
the stylish
the upstanding citizen
the utterly fluffy
the wonderful
COURT: PUNISHMENT
appallingly filthy
corpse looter
dull
feebleminded
i got punished
i got punished and all i got was this lousy title
i promise i won't do it again
insignificant
lying
malingering
naughty spawn
necrokleptomaniac
offensive
pillock
pointless
repentant
reprobate
shopkeeper murderer
silly spammy git
sitting in the corner
smelly
tantrum thrower
too stupid to live
vagrant
very sorry
very very sorry
waste of space
whinging
COUNCIL: DJB
sultan 
sultana 
shai al-khasa 
sitt al-khasa 
shai al-ri'asa 
sitt al-ri'asa 
shai ishquaraya 
sitt ishquaraya 
shai a'daha 
sitt a'daha 
nawab 
qasar 
mazrat 
effendi 
ya'uq 
mutasharid 
ishqaraya 
naughty spawn 
kill stealer 
feebleminded 
idiotic 
offensive 
corpse looter 
cat hating 
heathen 
foreign dog 
infidel 
shopkeeper murderer 
destitute 
parasitic 
hated 
cowardly 
criminal 
felon 
GENUA
m 
monsieur
mlle 
mademoiselle
mme 
madame
QUEST: POINTS
well travelled
persistent
DEBATERS:
diplomatic 
uncreative 
THIEVES
fingers
ruinous
WARRIORS
centurion
chef
headmaster
headmistress
impaler
pulveriser
WITCHES
destined
nasty
terrible
FOOLS
pious
WIZARDS
erratic mechanic
arcana
mysterious
PRIESTS
healer
saintly
templar
outcast
ASSASSINS
lethal
venomous
ALL
antiquated
archaic
axe-master
bloodthirsty
bruiser
captain
champion
competent
contender
crimewave
crusher
cultured
cutthroat
deckhand
decrepit
diplomatic
duelist
elementalist
energetic
exterminator
festive
filthy
flatulent
fossilized
gifted
golden
knifey
legendary
literate
masterful
medical
miner
multilingual
murse
mythical
nimble
nurse
obsolete
old
old man
old woman
opulent
paranoid
perverse
prehistoric
rock-hard
rouge
senile
shieldmaster
shieldmistress
staffmaster
staffmistress
stormrider
swordmaster
swordmistress
unburiable
unexpected
unlucky
unstoppable
venerable
versatile
virtuoso
wealthy
]]
