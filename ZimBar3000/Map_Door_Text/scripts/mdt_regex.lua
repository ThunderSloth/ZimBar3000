-------------------------------------------------------------------------------
--  REGULAR EXPRESSIONS
-------------------------------------------------------------------------------
function mdt_get_regex()
	local regex = {}
	for _, v in ipairs({"titles", "xp"}) do
		local f = io.open(GetPluginInfo(GetPluginID (), 20):gsub("\\([A-Za-z_]+)\\$", "\\shared\\")..v..".txt", 'r')
		regex[v] = Trim(assert(f:read("*a"), "Can't locate "..v..".txt"))
		f:close()	
	end
	mdt.regex = {
		titles   = rex.new(regex.titles),
		xp = rex.new(regex.xp),
		map_door_text = rex.new([[
(?(DEFINE)
(?'direction'(?<ns>north|south)?(?(ns)(east|west)?|(east|west)))
(?'number'(one|two|three|four|five))
(?'positions'(((?P>direction)(,| and)? )+))
(?'locations'((?P>number) (?P>direction)((,| and)? |))+)
(?'vision'[Tt]he limit of your vision is (?P>locations)from here( and)?(, | |[.]$))
(?'doors'([Aa] )?[Dd]oors? (?P>positions)of ((?P>locations)|here(, | |))+)
(?'exits'([Aa]n? (hard to see through )?)?[Ee]xits? (?P>positions)of ((?P>locations)|here(, | |))+)
(?'population'(?! ?(((?P>vision)|(?P>doors)|(?P>exits)))).*?(?P>locations)(?=(\.|(?P>population)|(?P>vision)|(?P>doors)|(?P>exits))))
)(?# 
MAP DOOR TEXT:
)(?:(?<VISION>(?P>vision))|(?<DOORS>(?P>doors))|(?<EXITS>(?P>exits))|(?<POPULATION>(?P>population)))[.]?]]),
		path = rex.new([[
(?(DEFINE)
(?'direction'(?<ns>north|south)?(?(ns)(east|west)?|(east|west)))
(?'number'(one|two|three|four|five)))(?#
 PATH:
) (?<NUMBER>(?P>number)) (?<DIRECTION>(?P>direction))(,| |$)]]),
		direction = rex.new([[(?#
 DIRECTION:
)(?<DIRECTION>(?<ns>north|south)?(?(ns)(east|west)?|(east|west)))(,| |$)]]),
		thyngs = rex.new([[
(?(DEFINE)
(?'direction'(?<ns>north|south)?(?(ns)(east|west)?|(east|west)))
(?'number'(one|two|three|four|five))
(?'path' (is|are) (?P>number) (?P>direction).*$)
(?'deliminator'(, (?!\w+ Horseman)|(?<!orange|black) and (?!(white|yellow|orange|red|blue|green|tan|purple) )))
(?'thyng'.*?(?=((?P>deliminator)|(?P>path))))
)(?#
 MOB/PLAYER:
)(?<THYNG>(?P>thyng))((?<DELIMINATOR>(?P>deliminator))|(?P>path))]]),
		players = rex.new([[(?#
PLAYER:		
)(\\u001b\[4zMXP<(C )?(?<colour>.*?)MXP>)+(?<player>.*)\\u001b\[3z]]),
		remainder = rex.new(
[[^(?:(?:(an?|one)|(two)|(three)|(four)|(five)|(six)|(seven)|(eight)|(nine)|(ten)|(eleven)|(twelve)|(thirteen)|(fourteen)|(fifteen)|(sixteen)|(seventeen)|(eighteen)|(nineteen)|(twenty)|(many)) )?(?#
 REMAINDER: 00
)((?<xp00ss_sses_>.*(?=ss(es)?))|(?<xp00y_ies_>.*?(?=(y|ies)))|(?<xp00man_men_>.*?(?=m[ea]n))|(?<xp00_s_>.*?(?=s?)))(ss(es)?|y|ies|m[ea]n|s)?(?<hiding> [(]hiding[)])?$]]),
	}
end
