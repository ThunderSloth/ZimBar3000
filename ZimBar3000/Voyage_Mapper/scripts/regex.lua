function voyage_get_regex()
	local f = io.open(GetPluginInfo(GetPluginID (), 20):gsub("\\([A-Za-z_]+)\\$", "\\shared\\").."titles.txt", 'r')
	local title_regex = Trim(assert(f:read("*a"), "Can't locate titles.txt"))
	f:close()
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
        titles = rex.new(title_regex),
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
