--------------------------------------------------------------------------------
--   REGULAR EXPRESSIONS
--------------------------------------------------------------------------------
function medina_get_regex()
	regex = {
		verbiage = rex.new(" (?<verbiage>(is|are) \\w*?ing ([io]n the \\w*? )?here[. ])"),
		titles   = rex.new(
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
(?'debaters'(diplomatic|uncreative))
(?'netdead'the netdead statue of)(?'zombie'zombie))(?#
 TITLE REGEX: 
)^(?<title>(?P>assassins)|(?P>priests)|(?P>thieves)|(?P>witches)|(?P>wizards)|(?P>council_am)|(?P>court_positive)|(?P>court_punishment)|(?P>council_djb)|(?P>achievements_thieves)|(?P>achievements_warriors)|(?P>achievements_witches)|(?P>achievements_fools)|(?P>achievements_wizards)|(?P>achievements_priests)|(?P>achievements_assassins)|(?P>achievements_all)|(?P>quest_points)|(?P>general)|(?P>genua)|(?P>ghosts)|(?P>musketeers)|(?P>debaters)|(?P>netdead)|(?P>zombie)) ]])
}
end
