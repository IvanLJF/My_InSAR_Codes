;
; Egg with functions like DORIS.
; 
; The eggs are from doris processor.cc
FUNCTION TLI_EGG, line=line
  
  quotes=[$
    "tip: Check out www.sasmac.cn/portal_space",$
    "tip: For RADARSAT, use polyfit orbit interpolation, not approximation.",$
    "tip: cpxfiddle is a nifty little utility.",$
    "tip: dateconv is a nifty little utility.",$
    "GMT is a great package.",$
    "The only thing we have to fear is fear itself.",$
    '2b || !2b = 1',$
    "Sent me better quotes. Quick.",$
    "The whole is more than the sum of its parts.",$
    "To Thales the primary question was not what do we know but how do we know it.",$
    "For the things of this world cannot be made known without a knowledge of mathematics.",$
    "Life is a school of probability.",$
    '"Obvious" is the most dangerous word in mathematics.',$
    "An expert is a man who has made all the mistakes, which can be made in a very narrow field.",$
    "Structures are the weapons of the mathematician.",$
    "A witty statesman said, you might prove anything by figures.",$
    "Men pass away, but their deeds abide.",$
    "It is a good thing for an uneducated man to read books of quotations.", $
    "Mathematics is written for mathematicians.",$
    "Revolutions never occur in mathematics.",$
    "It is easier to square the circle than to get round a mathematician.",$
    "Cognito ergo sum. 'I think, therefore I am.'",$
    "It is not enough to have a good mind. The main thing is to use it well.",$
    "From a drop of water a logician could predict an Atlantic or a Niagara.",$
    "I don't believe in mathematics.",$
    "Imagination is more important than knowledge.",$
    "A Mathematician is a machine for turning coffee into theorems.",$
    "Whenever you can, count.", $
    "Mathematics is a language.",$
    "One should always generalize.",$
    "Statistics: the mathematical theory of ignorance.",$
    "When we ask advice, we are usually looking for an accomplice.",$
    "What we know is not much. What we do not know is immense.",$
    "Medicine makes people ill, mathematics make them sad and theology makes them sinful.",$
    "A great truth is a truth whose opposite is also a great truth.",$
    "I feign no hypotheses.",$
    "It is not certain that everything is uncertain.",$
    "Though this be madness, yet there is method in it.", $
    "I have no faith in political arithmetic.",$
    "Fourier is a mathematical poem.",$
    "We think in generalities, but we live in details.",$
    "I think that God in creating man somewhat overestimated his ability.",$
    "Add little to little and there will be a big pile.",$
    "Computers in the future may weigh no more than 1.5 tons. (1949)",$
    "There is no reason anyone would want a computer in their home. (1977)",$
    "Heavier-than-air flying machines are impossible. (1895)",$
    "Everything that can be invented has been invented. (1899)",$
    '640K ought to be enough for anybody. (1981)',$
    "Pentiums melt in your PC, not in your hand.",$
    "Always remember you're unique, just like everyone else.",$
    "Ever notice how fast Windows runs? Neither did I.",$
    "Double your drive space - delete Windows!",$
    "Circular definition: see Definition, circular.",$
    '43.3% of statistics are meaningless.',$
    "Very funny, Scotty. Now beam down my clothes.",$
    "I've got a problem. I say everything twice",$
    "Don't insult the alligator till after you cross the river.",$
    "Black holes are where God divided by zero.", $
    ">>make fire"+STRING(10b)+"Make: Don't know how to make fire. Stop.",$
    ">>why not?"+STRING(10b)+"No match.",$
    ">>gotta light?"+STRING(10b)+"No match.",$
    ">>!1984"+STRING(10b)+" 1984: Event not found. # (on some systems)",$
    ">>How's my lovemaking?"+STRING(10b)+"Unmatched.",$
    ">>How would you rate his incompetence?"+STRING(10b)+"Unmatched.",$
    ">>[Where is Jimmy Hoffa?"+STRING(10b)+"Missing ].",$
    ">>[Where is my brain?"+STRING(10b)+"Missing ].",$
    ">>^How did the sex change^ operation go?"+STRING(10b)+"Modifier failed.",$
    ">>tar x 'my love life'"+STRING(10b)+"tar: my love life does not exist",$
    "This time it will surely run.",$
    "Bug? That's not a bug, that's a feature.",$
    "It's redundant! It's redundant!",$
    "cpxfiddle is a great program.",$
    "The shortest path between two truths in the real domain passes through the complex domain.",$
    "You have a tendency to feel you are superior to most computers.",$
    "The first 90% of a project takes 90% of the time.",$
    "The last 10% of a project takes 90% of the time.",$
    "Any given program, when running, is obsolete.",$
    "Any given program costs more and takes longer.",$
    "If a program is useful, it will have to be changed.", $
    "If a program is useless, it will have to be documented.",$
    "Any given program will expand to fill all available memory.",$
    "The value of a program is porportional to the weight of its output.",$
    "Program complexity grows until it exceeds the capability of the programmer who must maintain it.",$
    "Make it possible for programmers to write programs in English\n\tand you will find that programmers cannot write in English.",$
    "On a helmet mounted mirror used by US cyclists: 'REMEMBER, OBJECTS IN THE MIRROR ARE ACTUALLY BEHIND YOU.'",$
    "On a New Zealand insect spray 'THIS PRODUCT NOT TESTED ON ANIMALS.'",$
    "In some countries, on the bottom of Coke bottles:'OPEN OTHER END.'",$
    "On a Sears hairdryer: 'DO NOT USE WHILE SLEEPING.'",$
    "On a bar of Dial soap: 'DIRECTIONS - USE LIKE REGULAR SOAP.'", $
    "On a Korean kitchen knife:'WARNING KEEP OUT OF CHILDREN.'",$
    "On an American Airlines packet of nuts:'INSTRUCTIONS - OPEN PACKET, EAT NUTS.'",$
    "On a child's superman costume:'WEARING OF THIS GARMENT DOES NOT ENABLE YOU TO FLY.'",$
    "Looking at wrapped interferograms is like running in circles.",$
    "Conversation equals conservation (proposition with thesis Ramon Hanssen).",$
    "Unlikely children's book title:"+STRING(10b)+"'Curios George and the High-Voltage Fence'.",$
    "Unlikely children's book title:"+STRING(10b)+"'Controlling the Playground: Respect through Fear'.",$
    "Unlikely children's book title:"+STRING(10b)+"'Mr Fork and Ms Electrical Outlet Become Friends'.",$
    "Unlikely children's book title:"+STRING(10b)+"'Strangers Have the Best Candy'.",$
    "Unlikely children's book title:"+STRING(10b)+"'Daddy Drinks Because You Cry'.",$
    "Stanley looked quite bored and somewhat detached, but then penguins often do.",$
    "Trouble with Windows? Reboot. Trouble with Unix? Be root.",$
    "The good thing about standards is that there are so many to choose from.",$
    "You can always count on people to do the right thing, after they have exhausted all the alternatives.",$
    "Where there is matter, there is geometry.",$
    "The simplest schoolboy is now familiar with facts for which Archimedes would have sacrificed his life.",$
    "Get the fastest fourier transform in the west at http://www.fftw.org/",$
    "See http://www.gnu.org/ for compiler updates, etc.",$
    "You can only find truth with logic if you have already found truth without it.",$
    "Everything should be made as simple as possible, but not simpler.",$
    "Seek simplicity, and distrust it.",$
    "Descartes commanded the future from his study more than Napoleon from the throne.",$
    "Say what you know, do what you must, come what may.",$
    "To the devil with those who published before us.",$
    "The words figure and fictitious both derive from the same Latin root, fingere. Beware!",$
    "The best material model of a cat is another, or preferably the same, cat.",$
    "He who loves practice without theory is like the sailor who boards ship without a rudder and compass.",$
    "Nature uses as little as possible of anything.",$
    "Mathematics is not yet ready for such problems.",$
    "You can only find truth with logic if you have already found truth without it.", $
    "Natural selection is a mechanism for generating an exceedingly high degree of improbability.",$
    "Similar figures exist only in pure geometry.",$
    "Writing briefly takes far more time than writing at length.",$
    "Like the crest of a peacock so is mathematics at the head of all knowledge.",$
    "The real danger is not that computers will begin to think like men, but that men will begin to think like computers.",$
    "Why did the blond stare at the orange juice? it said concentrate.",$
    "Hofstadter's Law: It always takes longer than you expect, even when you take into account Hofstadter's Law.",$
    "It can be of no practical use to know that Pi is irrational, but if we can know, it surely would be intolerable not to know.",$
    "Life is a complex, it has real and imaginary parts.",$
    "Beauty can be perceived but not explained.",$
    "Programming is like sex: one mistake and you have to support it for the rest of your life. [Michael Sinz]",$
    "I wish you were here and I was there [me].",$
    "In mathematics you dont understand things, you just get used to them [Neumann].",$
    "A man is incomplete until he is married. After that, he is finished [Zsa Zsa Gabor].",$
    "Unlikely children's book title:"+STRING(10b)+"'The Kids Guide to Hitchhiking'.", $
    "Unlikely children's book title:"+STRING(10b)+"'Whining, Kicking and Crying to Get Your Way'.",$
    "Unlikely children's book title:"+STRING(10b)+"'Dads New Wife Robert'.",$
    "Unlikely children's book title:"+STRING(10b)+"'The Little Sissy Who Snitched'." $
    ]
  IF N_ELEMENTS(line) EQ 0 THEN BEGIN
    temp=RANDOMU(seed)
    lines=N_ELEMENTS(quotes)
    line_i=LONG(temp*lines)
  ENDIF ELSE BEGIN
    line_i=LONG(line)
  ENDELSE
  
  RETURN, quotes[line_i]
  
END