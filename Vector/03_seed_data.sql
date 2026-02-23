-- ============================================================================
-- 03_seed_data.sql
-- Seeds circuits and 50+ iconic F1 race recaps spanning 1976-2024.
--
-- Each recap is a rich 2-4 sentence narrative designed to demonstrate the
-- power of semantic search. Keyword search will struggle to match concepts
-- like "rain drama" or "last-lap heartbreak" because the recaps use varied
-- language to describe similar themes.
--
-- RecapEmbedding is left NULL — populated in script 06.
-- ============================================================================

USE VectorF1;
GO

-- ── Circuits ──────────────────────────────────────────────────────────────

INSERT INTO dbo.Circuits (CircuitId, CircuitName, Country, City, LengthKm, CircuitType) VALUES
( 1, 'Circuit de Monaco',           'Monaco',        'Monte Carlo',    3.34, 'Street'),
( 2, 'Silverstone Circuit',         'United Kingdom', 'Silverstone',    5.89, 'Permanent'),
( 3, 'Monza',                       'Italy',          'Monza',          5.79, 'Permanent'),
( 4, 'Spa-Francorchamps',           'Belgium',        'Stavelot',       7.00, 'Permanent'),
( 5, 'Interlagos',                  'Brazil',         'Sao Paulo',      4.31, 'Permanent'),
( 6, 'Suzuka',                      'Japan',          'Suzuka',         5.81, 'Permanent'),
( 7, 'Circuit Gilles Villeneuve',   'Canada',         'Montreal',       4.36, 'Hybrid'),
( 8, 'Hungaroring',                 'Hungary',        'Budapest',       4.38, 'Permanent'),
( 9, 'Bahrain International',       'Bahrain',        'Sakhir',         5.41, 'Permanent'),
(10, 'Yas Marina',                  'UAE',            'Abu Dhabi',      5.28, 'Hybrid'),
(11, 'Circuit of the Americas',     'United States',  'Austin',         5.51, 'Permanent'),
(12, 'Nurburgring',                 'Germany',        'Nurburg',        5.15, 'Permanent'),
(13, 'Imola',                       'Italy',          'Imola',          4.91, 'Permanent'),
(14, 'Jeddah Corniche',             'Saudi Arabia',   'Jeddah',         6.17, 'Street'),
(15, 'Marina Bay',                  'Singapore',      'Singapore',      4.94, 'Street'),
(16, 'Red Bull Ring',               'Austria',        'Spielberg',      4.32, 'Permanent'),
(17, 'Hockenheimring',              'Germany',        'Hockenheim',     4.57, 'Permanent'),
(18, 'Indianapolis Motor Speedway', 'United States',  'Indianapolis',   4.19, 'Permanent'),
(19, 'Donington Park',              'United Kingdom', 'Donington',      4.02, 'Permanent'),
(20, 'Las Vegas Street Circuit',    'United States',  'Las Vegas',      6.12, 'Street'),
(21, 'Albert Park',                 'Australia',      'Melbourne',      5.28, 'Hybrid'),
(22, 'Baku City Circuit',           'Azerbaijan',     'Baku',           6.00, 'Street'),
(23, 'Losail International',        'Qatar',          'Lusail',         5.38, 'Permanent'),
(24, 'Sakhir Outer',                'Bahrain',        'Sakhir',         3.54, 'Permanent'),
(25, 'Paul Ricard',                 'France',         'Le Castellet',   5.84, 'Permanent');
GO

PRINT 'Circuits seeded: 25 circuits.';
GO

-- ── Race Recaps ───────────────────────────────────────────────────────────

INSERT INTO dbo.RaceRecaps (Year, CircuitId, RaceName, Winner, WinnerTeam, Weather, SafetyCar, RedFlag, ChampionshipDecider, Recap) VALUES

-- === RAIN CLASSICS ===
(1976, 12, '1976 German Grand Prix', 'James Hunt', 'McLaren', 'Wet', 1, 1, 0,
 'Niki Lauda suffered a horrifying fiery crash at the Nurburgring Nordschleife when his Ferrari burst into flames after hitting a wall. Trapped in the burning wreckage, fellow drivers pulled him free with severe burns. The race was restarted and James Hunt eventually won. Lauda''s miraculous return to racing just six weeks later remains one of the most courageous comebacks in sports history.'),

(1996, 1, '1996 Monaco Grand Prix', 'Olivier Panis', 'Ligier', 'Wet', 1, 0, 0,
 'Torrential rain turned Monaco into an elimination event as car after car crashed or retired in the treacherous conditions. Only three cars were running at the finish. Olivier Panis, driving for the tiny Ligier team, produced a masterful wet-weather drive to claim an utterly improbable victory that nobody saw coming. It was one of the greatest underdog triumphs in Formula 1 history.'),

(1998, 4, '1998 Belgian Grand Prix', 'Damon Hill', 'Jordan', 'Wet', 1, 1, 0,
 'A massive first-lap pileup at La Source in heavy rain took out thirteen cars, triggering a red flag. The restart was equally chaotic with Michael Schumacher colliding with David Coulthard while lapping him, sending Schumacher into a fury. Damon Hill capitalized on the mayhem to deliver Jordan their first and only Formula 1 victory in an emotional finish at a rain-soaked Spa.'),

(2008, 5, '2008 Brazilian Grand Prix', 'Felipe Massa', 'Ferrari', 'Wet', 0, 0, 1,
 'The championship came down to the final corner of the final race. Lewis Hamilton needed to finish fifth to claim his first title, but rain arrived in the closing laps and he slipped to sixth behind Toyota''s Timo Glock. Massa crossed the line first and his garage erupted in celebration — for thirty agonizing seconds. Then Glock''s rain tires failed on the final bend, Hamilton passed him for fifth, and the championship swung to McLaren by a single point in the most dramatic conclusion imaginable.'),

(2008, 2, '2008 British Grand Prix', 'Lewis Hamilton', 'McLaren', 'Wet', 0, 0, 0,
 'Hamilton delivered one of the most dominant wet-weather performances ever witnessed at Silverstone. While others aquaplaned off the track and struggled for grip, Hamilton drove his McLaren as if on rails, building a lead of over a minute. He won by 68 seconds in conditions that destroyed the rest of the field. The home crowd watched in awe as their hero painted a masterpiece in the rain.'),

(2011, 7, '2011 Canadian Grand Prix', 'Jenson Button', 'McLaren', 'Wet', 1, 1, 0,
 'The longest race in F1 history at over four hours featured two red-flag stoppages for biblical rain. Jenson Button dropped to last place after multiple incidents, a drive-through penalty, and a puncture. What followed was the greatest comeback drive ever: Button carved through the entire field in treacherous conditions, overtaking Sebastian Vettel on the final lap when the Red Bull made an error on a damp track. From dead last to victory — an immortal drive.'),

(2019, 17, '2019 German Grand Prix', 'Max Verstappen', 'Red Bull', 'Mixed', 1, 0, 0,
 'A dry race was turned upside down when sudden rain arrived at Hockenheim. Both Ferraris crashed out while leading, Mercedes made multiple strategic blunders, and the running order was reshuffled repeatedly. Verstappen navigated the chaos perfectly while cars spun off around him. Daniil Kvyat scored an unlikely podium and the race produced one of the most unpredictable and entertaining spectacles of the modern era.'),

(2021, 4, '2021 Belgian Grand Prix', 'Max Verstappen', 'Red Bull', 'Wet', 0, 1, 0,
 'Persistent heavy rain made Spa-Francorchamps undriveable for the entire afternoon. After hours of delays, the race was run for just two laps behind the safety car before being red-flagged permanently. Half points were controversially awarded based on the qualifying order. Fans who sat in cold rain all day saw no actual racing, sparking widespread criticism and rule changes. It was the most farcical non-race in modern F1 history.'),

-- === CHAMPIONSHIP DECIDERS ===
(2007, 5, '2007 Brazilian Grand Prix', 'Kimi Raikkonen', 'Ferrari', 'Dry', 0, 0, 1,
 'Three drivers arrived at the season finale in mathematical contention for the title. Lewis Hamilton needed only a decent finish to become the youngest champion, but his McLaren suffered a gearbox glitch that dropped him far down the field. Fernando Alonso pushed hard but could not make up enough ground. Kimi Raikkonen quietly drove a perfect race from the front, stealing the championship by a single point in one of the most unlikely title heists ever.'),

(2010, 10, '2010 Abu Dhabi Grand Prix', 'Sebastian Vettel', 'Red Bull', 'Dry', 1, 0, 1,
 'Four drivers entered the final race with a mathematical shot at the title. Championship leader Fernando Alonso''s Ferrari team made a catastrophic strategic error, leaving him stuck behind Vitaly Petrov''s Renault for the entire race. While Alonso languished in seventh, Sebastian Vettel led from start to finish to become the youngest World Champion in history at 23 years old. Ferrari''s strategy blunder was analyzed for years afterward.'),

(2012, 5, '2012 Brazilian Grand Prix', 'Jenson Button', 'McLaren', 'Wet', 1, 0, 1,
 'Sebastian Vettel arrived needing only to avoid a disaster, but disaster nearly struck when he was spun around on the first lap and dropped to last place. Rain came and went as Vettel fought an epic recovery drive through the field while Fernando Alonso did everything he could from second place. Vettel finished sixth — just enough to seal his third consecutive title by three points in a race that produced unbearable tension from start to finish.'),

(2016, 10, '2016 Abu Dhabi Grand Prix', 'Lewis Hamilton', 'Mercedes', 'Dry', 0, 0, 1,
 'The title fight between Mercedes teammates reached a bitter climax. Hamilton led from pole and deliberately drove slowly to back Nico Rosberg into traffic, trying to get other cars to overtake his rival. Mercedes ordered Hamilton to speed up but he refused. Despite Hamilton''s tactics, Rosberg held his nerve in second place to clinch his first and only World Championship. Rosberg shocked the world by retiring from F1 five days later.'),

(2021, 10, '2021 Abu Dhabi Grand Prix', 'Max Verstappen', 'Red Bull', 'Dry', 1, 0, 1,
 'The most controversial championship finish in F1 history. Hamilton dominated the race and held a commanding lead with five laps remaining when a late safety car compressed the field. Race director Michael Masi made the unprecedented decision to let only the cars between Hamilton and Verstappen unlap themselves, setting up a final-lap shootout. Verstappen, on fresh soft tires, passed Hamilton into Turn 5 to steal the championship. The decision sparked protests, legal challenges, and ultimately led to Masi''s removal. Opinions on the legitimacy of the result remain bitterly divided.'),

-- === CRASHES AND SAFETY ===
(1994, 13, '1994 San Marino Grand Prix', 'Michael Schumacher', 'Benetton', 'Dry', 1, 1, 0,
 'The darkest weekend in modern Formula 1 history. Roland Ratzenberger was killed in qualifying on Saturday, and the following day three-time champion Ayrton Senna died when his Williams left the road at Tamburello corner. The paddock was stunned into grief as the sport confronted its vulnerability. Schumacher won a race nobody wanted to remember. The tragedy transformed F1 safety forever — no driver would die in a race for 20 years.'),

(2020, 9, '2020 Bahrain Grand Prix', 'Lewis Hamilton', 'Mercedes', 'Dry', 1, 1, 0,
 'Romain Grosjean''s Haas split in half and burst into a fireball after piercing the metal barrier at 220 km/h on the opening lap. Grosjean was trapped in a burning inferno for 28 seconds before climbing out with burns to his hands — a survival that seemed miraculous. The halo cockpit protection device, once criticized for aesthetics, was universally credited with saving his life. Hamilton won the restarted race, but Grosjean''s escape was the story that transcended the sport.'),

(2022, 2, '2022 British Grand Prix', 'Carlos Sainz', 'Ferrari', 'Dry', 1, 1, 0,
 'Zhou Guanyu''s Alfa Romeo was launched upside down at high speed on the first lap, sliding inverted across the gravel before flipping over the tire barrier. The car came to rest wedged between the barrier and catch fence. Despite the terrifying impact, Zhou emerged uninjured thanks to the halo and modern safety cell. Carlos Sainz claimed his maiden Formula 1 victory in the restarted race, but it was Zhou''s miraculous survival that dominated the headlines.'),

-- === INCREDIBLE COMEBACKS ===
(2005, 6, '2005 Japanese Grand Prix', 'Kimi Raikkonen', 'McLaren', 'Dry', 0, 0, 0,
 'Raikkonen started 17th on the grid after a penalty but delivered one of the most electrifying drives in Suzuka history. He carved through the field with relentless pace, making audacious overtakes lap after lap. The decisive move came with two laps remaining when he swept past Giancarlo Fisichella around the outside of the 130R corner at over 300 km/h — a pass that defied physics and cemented his reputation as the fastest driver of his generation.'),

(2020, 24, '2020 Sakhir Grand Prix', 'Sergio Perez', 'Racing Point', 'Dry', 1, 0, 0,
 'Perez dropped to last place on the opening lap after contact and seemed destined for a pointless afternoon. Over the next 87 laps at Bahrain''s short outer circuit, he produced a sublime recovery drive to take the lead when Mercedes bungled George Russell''s pit stop. Perez held on for his first-ever Formula 1 victory in his 190th start, breaking down in tears on the radio. It was the drive that secured him a seat at Red Bull for 2021.'),

(2020, 3, '2020 Italian Grand Prix', 'Pierre Gasly', 'AlphaTauri', 'Dry', 1, 1, 0,
 'Red-flagged after Charles Leclerc''s massive crash at Parabolica, the race restarted into pure chaos. Hamilton received a penalty for entering a closed pit lane, and the shuffled order produced an extraordinary podium. Pierre Gasly, dropped by Red Bull just a year earlier, held off Carlos Sainz in a breathtaking final-lap battle to win at Monza for the tiny AlphaTauri team. His raw emotion on the radio — barely able to speak through tears — was one of the decade''s most moving moments.'),

(1993, 19, '1993 European Grand Prix', 'Ayrton Senna', 'McLaren', 'Wet', 0, 0, 0,
 'Senna''s opening lap at a rain-soaked Donington Park is regarded as the greatest single lap in Formula 1 history. Starting fifth, he passed four cars in a breathtaking display of wet-weather mastery, taking the lead before completing the first tour. He then pulled away to lap everyone up to second place in his underpowered McLaren. It was a transcendent performance that elevated driving beyond sport into art.'),

-- === UNDERDOG VICTORIES AND SURPRISES ===
(2005, 18, '2005 United States Grand Prix', 'Michael Schumacher', 'Ferrari', 'Dry', 0, 0, 0,
 'A tire safety crisis became the most embarrassing episode in F1 history. Every team running Michelin tires withdrew after the formation lap because Michelin could not guarantee their tires were safe through the banked Turn 13. Only six cars running Bridgestone tires took the start. The Indianapolis crowd booed furiously as Ferrari staged a hollow one-two finish in front of 100,000 outraged fans. The debacle led to fundamental changes in F1''s tire regulations.'),

(2016, 4, '2016 Spanish Grand Prix', 'Max Verstappen', 'Red Bull', 'Dry', 0, 0, 0,
 'In his very first race for Red Bull after being promoted mid-season from Toro Rosso, 18-year-old Max Verstappen became the youngest race winner in Formula 1 history. He benefited from a first-lap collision between the Mercedes pair of Hamilton and Rosberg, then held off Raikkonen''s Ferrari on an alternative strategy with mature racecraft that belied his age. A star was born — the teenager who would reshape F1''s competitive landscape.'),

(2008, 3, '2008 Italian Grand Prix', 'Sebastian Vettel', 'Toro Rosso', 'Wet', 0, 0, 0,
 'Twenty-one-year-old Vettel stunned the paddock by putting the tiny Toro Rosso on pole position in wet qualifying at Monza. In the race, he converted pole into a dominant lights-to-flag victory, becoming the youngest race winner in F1 history at the time. The little sister team of Red Bull had beaten everyone, including the parent team. Vettel cried on the podium — it was the drive that announced a future four-time world champion.'),

(2024, 1, '2024 Monaco Grand Prix', 'Charles Leclerc', 'Ferrari', 'Dry', 0, 0, 0,
 'After years of heartbreak at his home race — including mechanical failures and strategic errors when victory seemed certain — Charles Leclerc finally won the Monaco Grand Prix. The emotional weight of the moment overwhelmed him as he crossed the line, dedicating the victory to his late father who had watched him dream of this moment as a child racing karts on these same streets. Monaco erupted in celebration for their local hero in one of the most emotionally charged victories in recent memory.'),

-- === TEAM DRAMAS AND RIVALRIES ===
(2014, 9, '2014 Bahrain Grand Prix', 'Lewis Hamilton', 'Mercedes', 'Dry', 1, 0, 0,
 'The Mercedes teammates staged a spectacular wheel-to-wheel battle under the floodlights of Bahrain, trading positions multiple times with millimeters to spare. Hamilton and Rosberg fought hard but fair in a thrilling duel that announced the start of an intense two-year rivalry. The racing was so compelling that many consider it the finest intra-team battle in a single race, a pure display of attacking and defending at the highest level.'),

(2019, 5, '2019 Brazilian Grand Prix', 'Max Verstappen', 'Red Bull', 'Dry', 1, 0, 0,
 'Verstappen won a dramatic and chaotic race, but the real story was Pierre Gasly''s podium finish for Toro Rosso after Hamilton received a penalty for colliding with Alexander Albon. The Ferrari teammates Leclerc and Vettel crashed into each other while fighting, ending both their races and sparking a bitter team feud. It was a race that produced fury, ecstasy, and heartbreak in equal measure.'),

(2021, 2, '2021 British Grand Prix', 'Lewis Hamilton', 'Mercedes', 'Dry', 1, 1, 0,
 'The defining flashpoint of the Hamilton-Verstappen rivalry. They collided at Copse corner on the opening lap, sending Verstappen into the barriers at 180 mph with a 51G impact. While Verstappen was taken to hospital for checks, Hamilton received a 10-second penalty but stormed back to win in front of his home crowd. Verstappen and Red Bull accused Hamilton of dangerous driving; Hamilton celebrated what he called his greatest victory. The controversy poisoned relations for the rest of the season.'),

(2021, 8, '2021 Hungarian Grand Prix', 'Esteban Ocon', 'Alpine', 'Mixed', 1, 1, 0,
 'Valtteri Bottas caused a massive first-corner pileup that eliminated multiple cars and triggered a red flag. On the restart, every driver pitted for dry tires except Hamilton, who was briefly left alone on the grid on wet tires before pitting a lap later, dropping to last. Verstappen''s damaged car could only manage ninth. Esteban Ocon inherited the lead and held off Sebastian Vettel to claim Alpine''s first-ever victory in one of the most bizarre and unpredictable races ever staged.'),

(2021, 3, '2021 Italian Grand Prix', 'Daniel Ricciardo', 'McLaren', 'Dry', 0, 1, 0,
 'Hamilton and Verstappen collided for the second time that season, this time at Monza''s chicane. Verstappen''s car rode over Hamilton''s, with the halo again proving its worth. Both drivers were out. Daniel Ricciardo led Lando Norris to a McLaren one-two — the team''s first victory since 2012. Ricciardo''s celebration with a victory shoey on the podium was pure joy, a moment of redemption after a difficult season.'),

-- === STRATEGIC MASTERCLASSES ===
(1998, 8, '1998 Hungarian Grand Prix', 'Michael Schumacher', 'Ferrari', 'Dry', 0, 0, 0,
 'Schumacher could not pass McLaren''s David Coulthard on the narrow Hungaroring track. Ferrari strategist Ross Brawn devised a radical three-stop strategy that required Schumacher to run qualifying-speed laps for an entire stint. Schumacher delivered, gaining enough time in the pit windows to leapfrog Coulthard and take victory through pure pace and flawless strategy. It was a textbook demonstration of how pit-stop strategy can win races without a single on-track overtake.'),

(2019, 8, '2019 Hungarian Grand Prix', 'Lewis Hamilton', 'Mercedes', 'Dry', 0, 0, 0,
 'Hamilton trailed Verstappen by nearly 20 seconds when Mercedes made the bold call to pit him for a second time onto fresh tires. The gamble seemed insane — Hamilton would need to make up a huge deficit and overtake Verstappen with just 20 laps remaining. But on fresh rubber, Hamilton was a second per lap faster and hunted down the Red Bull, pulling off a clinical outside pass at Turn 1. A strategic masterstroke that showed why Mercedes dominated the turbo hybrid era.'),

(2023, 15, '2023 Singapore Grand Prix', 'Carlos Sainz', 'Ferrari', 'Dry', 1, 0, 0,
 'Sainz executed a perfect lights-to-flag victory at Marina Bay, controlling the pace from pole position while managing tire degradation in Singapore''s brutal heat and humidity. What made it remarkable was that he did it while Verstappen and Red Bull were on a nine-race winning streak that seemed unbreakable. Sainz ended the dominant run with patient, measured driving — proving that consistency and tire management could still defeat the fastest car on the grid.'),

-- === EMOTIONAL AND HISTORIC ===
(1991, 5, '1991 Brazilian Grand Prix', 'Ayrton Senna', 'McLaren', 'Dry', 0, 0, 0,
 'Senna had never won his home race in Brazil, and the pressure of expectation weighed heavily. During the race his McLaren''s gearbox began failing, leaving him stuck in sixth gear for the final laps while fighting excruciating physical pain from wrestling the heavy steering. He crossed the line with tears streaming down his face, so exhausted he could barely lift the trophy. It was a victory forged through sheer willpower, and the image of Senna crying on the podium is among F1''s most iconic.'),

(1991, 7, '1991 Canadian Grand Prix', 'Nelson Piquet', 'Benetton', 'Dry', 0, 0, 0,
 'Leading comfortably on the final lap, Nigel Mansell waved to the crowd in premature celebration. As he raised his hand, his car''s engine stalled. Mansell sat motionless in his Williams as Piquet cruised past to steal the victory. It became one of the most embarrassing and memorable moments in motorsport — a lesson in never celebrating before the checkered flag that is retold to every generation of racing drivers.'),

(2022, 10, '2022 Abu Dhabi Grand Prix', 'Max Verstappen', 'Red Bull', 'Dry', 0, 0, 0,
 'Sebastian Vettel''s final race in Formula 1 became a weekend-long celebration of one of the sport''s greatest champions. Drivers wore special tribute helmets, and the paddock was consumed by nostalgia and emotion. Vettel finished tenth in his final outing, scoring a point in his farewell. On the cool-down lap, drivers formed an impromptu convoy behind him as a guard of honor. The four-time champion retired as one of the most respected figures the sport has ever known.'),

(2023, 20, '2023 Las Vegas Grand Prix', 'Max Verstappen', 'Red Bull', 'Dry', 1, 0, 0,
 'Formula 1''s glamorous return to Las Vegas featured a night race down the neon-lit Strip in near-freezing temperatures. A loose drain cover destroyed Carlos Sainz''s car in practice, delaying the opening session. The race itself delivered genuine drama as Verstappen overtook Leclerc late on and the chilled conditions made tire management a puzzle. F1 under the lights of the Strip was a spectacle unlike anything the sport had seen before.'),

-- === MORE ICONIC MOMENTS ===
(2003, 5, '2003 Brazilian Grand Prix', 'Giancarlo Fisichella', 'Jordan', 'Wet', 1, 1, 0,
 'A rain-soaked Interlagos produced one of the most chaotic races in history. Cars crashed in waves on the flooded track, and the race was red-flagged after Mark Webber''s terrifying accident sent debris into the spectator area. Amid the confusion over the stopping point and results, Fisichella was eventually confirmed as the winner weeks later. Fernando Alonso had earlier survived his own violent crash, thankfully without serious injury. It was a race that pushed safety to its absolute limits.'),

(2014, 10, '2014 Abu Dhabi Grand Prix', 'Lewis Hamilton', 'Mercedes', 'Dry', 1, 0, 1,
 'With double points controversially on offer at the finale, Rosberg needed victory and Hamilton failures to win the title. Hamilton led from the start while Rosberg''s car developed an ERS problem that cost him pace, and he faded to 14th. Hamilton cruised to victory and his second World Championship. The double-points gimmick, universally criticized, was scrapped after this single season. Hamilton''s celebration was muted — the title fight had taken an emotional toll on both drivers.'),

(2017, 22, '2017 Azerbaijan Grand Prix', 'Daniel Ricciardo', 'Red Bull', 'Dry', 1, 1, 0,
 'The inaugural Baku street race delivered absolute carnage. Vettel deliberately drove into Hamilton''s car under the safety car in a road-rage incident. Both Red Bull drivers clashed and retired. Force India teammates Ocon and Perez battled so aggressively they crashed. Amid the chaos, Ricciardo and Lance Stroll — then a rookie — found themselves on the podium. The race was a soap opera on wheels, proving that street circuits and close walls breed drama.'),

(2010, 7, '2010 Canadian Grand Prix', 'Lewis Hamilton', 'McLaren', 'Dry', 1, 0, 0,
 'Hamilton was under enormous pressure to perform after a difficult start to the season. He qualified poorly but worked his way through the field with aggressive, committed overtaking that reminded everyone why he was champion. The race featured intense battles throughout, but Hamilton''s determination shone brightest as he brought his McLaren home for a crucial victory that reignited his title challenge.'),

(2018, 22, '2018 Azerbaijan Grand Prix', 'Lewis Hamilton', 'Mercedes', 'Dry', 1, 0, 0,
 'Baku delivered chaos again as the Red Bull teammates Verstappen and Ricciardo collided while fighting for position, eliminating both cars and causing a furious team reaction. Bottas was leading but suffered a tire failure on the final lap, handing victory to Hamilton in the most fortunate of circumstances. Vettel also fumbled a potential win with a lock-up while trying to pass. It was a race where fortune favored the calm.'),

(2021, 13, '2021 Emilia Romagna Grand Prix', 'Max Verstappen', 'Red Bull', 'Mixed', 1, 1, 0,
 'Hamilton and Verstappen nearly collided on the opening lap before the race was red-flagged for a multi-car accident. On the restart, Hamilton made a rare error, sliding wide at Tosa and getting beached in the gravel. He reverse-recovered but dropped to ninth. A subsequent red flag for Bottas and Russell''s high-speed collision gave Hamilton a chance to unlap himself. He recovered to finish second — a result that felt like a defeat for Mercedes and a victory for Verstappen.'),

(2021, 23, '2021 Qatar Grand Prix', 'Lewis Hamilton', 'Mercedes', 'Dry', 0, 0, 0,
 'With the championship reaching its crescendo, Hamilton delivered a crushing response to Verstappen''s previous victories. He led every lap from pole position in a dominant display of pace that left Verstappen helpless in second. Fernando Alonso delivered the race''s other memorable moment, finishing on the podium for the first time in seven years. Hamilton''s victory cut the gap and ensured the title fight would go to the wire.'),

(2021, 14, '2021 Saudi Arabian Grand Prix', 'Lewis Hamilton', 'Mercedes', 'Dry', 1, 1, 0,
 'The first race at Jeddah''s ultra-fast street circuit descended into chaos. Multiple red flags, safety cars, and aggressive driving created an atmosphere of barely controlled mayhem. Verstappen and Hamilton made contact when Verstappen appeared to brake-test Hamilton on the main straight. Hamilton eventually won after the stewards penalized Verstappen. The race left both camps furious and set the stage for the incendiary Abu Dhabi finale two weeks later.'),

(2022, 9, '2022 Bahrain Grand Prix', 'Charles Leclerc', 'Ferrari', 'Dry', 1, 0, 0,
 'Ferrari''s return to competitiveness after two lean years was confirmed dramatically when Leclerc and Verstappen staged a breathtaking late-race duel. They swapped positions three times in the closing laps before Leclerc pulled clear. Then both Red Bulls retired with mechanical failures on the final lap, gifting Ferrari a one-two and sending the tifosi into rapture. The new era of ground-effect cars had arrived, and Ferrari were back.'),

(2023, 9, '2023 Bahrain Grand Prix', 'Max Verstappen', 'Red Bull', 'Dry', 0, 0, 0,
 'Red Bull''s RB19 was so dominant that Verstappen won by over eleven seconds without breaking a sweat. It was the opening statement of a record-breaking season in which Verstappen would win 19 of 22 races. The gap to the rest of the field was so enormous that the race was essentially a procession, a harbinger of the most dominant campaign any driver has ever produced in the history of the sport.'),

(2015, 11, '2015 United States Grand Prix', 'Lewis Hamilton', 'Mercedes', 'Mixed', 1, 0, 1,
 'Hamilton clinched his third World Championship with a lights-to-flag victory at the Circuit of the Americas. Rain early in the race created mixed conditions, but Hamilton was untouchable throughout. With this title he equalled his hero Ayrton Senna''s tally of three championships. The celebration was euphoric — Hamilton standing on top of his Mercedes, arms raised in the Texas twilight, cementing his place among the all-time greats.'),

(2019, 21, '2019 Australian Grand Prix', 'Valtteri Bottas', 'Mercedes', 'Dry', 0, 0, 0,
 'Bottas arrived in Melbourne determined to reset his reputation after a winless 2018 campaign. He exploded off the line from second on the grid, passed Hamilton into Turn 1, and never looked back. His radio message after crossing the line — a defiant expletive celebrating his dominance — became an instant meme and rallying cry. It was a reminder that even in an era of Hamilton dominance, his teammate could deliver crushing performances.'),

(2020, 3, '2020 Tuscan Grand Prix', 'Lewis Hamilton', 'Mercedes', 'Dry', 1, 1, 0,
 'Formula 1''s first race at Mugello was a spectacular affair with two red flags and chaos throughout. A concertina collision on the main straight after a safety car restart wiped out multiple cars. Another restart produced more contact. Hamilton prevailed through the mayhem to win his 90th Grand Prix, moving ever closer to Schumacher''s record. The race proved that new venues and unfamiliar circuits produce unpredictable, thrilling racing.'),

(2022, 6, '2022 Japanese Grand Prix', 'Max Verstappen', 'Red Bull', 'Wet', 1, 1, 1,
 'Verstappen clinched his second championship in confusing circumstances at a rain-shortened Suzuka. The race was red-flagged after just two laps due to heavy rain, with Sainz''s stranded car creating a safety concern. When racing resumed, Verstappen dominated but initially thought he hadn''t scored enough points for the title due to reduced-distance rules. Only after a delay and points recalculation was it confirmed: Verstappen was champion. Even he seemed bewildered.'),

(2024, 10, '2024 Abu Dhabi Grand Prix', 'Lando Norris', 'McLaren', 'Dry', 0, 0, 0,
 'McLaren sealed their first Constructors'' Championship since 1998 in a supremely emotional season finale. Lando Norris led from start to finish while his teammate Oscar Piastri provided the support needed to keep Ferrari at bay. The team that had nearly gone bankrupt just five years earlier stood on top of the sport once again. Team principal Andrea Stella wept openly, and the orange-clad fans roared for a comeback story years in the making.');
GO

PRINT 'Race recaps seeded: 50 iconic F1 moments (1976-2024).';
PRINT 'RecapEmbedding column is NULL — run 06_generate_embeddings.sql to populate.';
PRINT '';
PRINT '=== Data ready. Proceed to 04_traditional_search.sql ===';
GO
