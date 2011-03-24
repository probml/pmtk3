data <- data.frame(Country = as.numeric(ases$Country), Continent = as.numeric(ases$Continent))

# "neither agree nor disagree" coded as a class
data$Protectionism.d <- recode(as.numeric(ases$Protectionism), '1:2=1; 3=2; 4:5=3; 6:7=NA')
data$Antiforeigner.d <- recode(as.numeric(ases$Antiforeigner), '1:2=1; 3=2; 4:5=3; 6:7=NA')
data$NationalTV.d <- recode(as.numeric(ases$NationalTV), '1:2=1; 3=2; 4:5=3; 6:7=NA')
data$Female.d <- recode(as.numeric(ases$Female), '1=1; 2=2')
data$Age10 <- recode(as.numeric(ases$Age), '1:3=1; 4:5=2; 6:7=3; 8:9=4; 10:11=5; 12:13=6') # continuous
data$SubjIncome <- recode(as.numeric(ases$SubjIncome),'1=5; 2=4; 3=3; 4=2; 5=1; 6=NA') # categorical
data$Education.ord <- recode(ases$Education, '0:6=1; 7:9=2; 10:12=3; 13:16=4; NA=NA; 79=NA; else=5') # categorical
# left, in between, right
data$Ideo10 <- recode(as.numeric(ases$Ideology), '1:3=1; 3:6=2; 7:10=3; 11:12=NA')
# PublicJob
data$Publicjob.d <- recode(as.numeric(ases$Publicjob), '1=1; 2=2; 3=3; 4=4; 5=5; 6=6; 7=NA') # categorical
data$Unionmember.d <- recode(as.numeric(ases$Unionmember), '1=1; 2=2; 3=NA') 
data$Employstatus.d <- recode(as.numeric(ases$Employstatus), '1=1; 2=2; 3=NA') 
data$Poliinterest.d <- recode(as.numeric(ases$Poliinterest), '1:2=1; 3:4=2; 5=NA')
data$Polisatis.d<- recode(as.numeric(ases$Polisatis), '1:2=1; 3=2; 4:5=3; 6=NA')
data$Localnews.rev <- recode(as.numeric(ases$Localnews), '1=3; 2=2; 3=2; 4=NA')  ## Follow local newspaper?
data$Nationalnews.rev <- recode(as.numeric(ases$Nationalnews), '1=3; 2=2; 3=2; 4=NA') ## Follow national newspaper?
data$Foreignnews.rev <- recode(as.numeric(ases$Foreignnews), '1=3; 2=2; 3=2; 4=NA') ## Follow foreign newspaper?
data$Govt.eff <- recode(as.numeric(ases$Govt.effectiveness), '1:2=1; 3=3; 4:5=3; 6:7=NA')
data$Govt.ability.d <- recode(as.numeric(ases$Govt.ability), '1:2=1; 3=3; 4:5=3; 6:7=NA')
data$Govt.economy.d <- recode(as.numeric(ases$Govt.economy), '1:2=1; 3:4=2; 5:6=NA')
data$Govt.unemploy.d <- recode(as.numeric(ases$Govt.unemploy), '1:2=1; 3:4=2; 5:6=NA')
data$Govt.corruption.d <- recode(as.numeric(ases$Govt.corruption), '1:2=1; 3:4=2; 5:6=NA')
data$Govt.crime.d <- recode(as.numeric(ases$Govt.crime), '1:2=1; 3:4=2; 5:6=NA')
data$Govt.immig.d <- recode(as.numeric(ases$Govt.immig), '1:2=1; 3:4=2; 5:6=NA')
data$Govt.envir.d <- recode(as.numeric(ases$Govt.envir), '1:2=1; 3:4=2; 5:6=NA')
data$Corruption.d <- recode(as.numeric(ases$Corruption),'1:2=1; 3=2; 4:5=3; 6:7=NA')
data$Poliskepticism1.d <- recode(as.numeric(ases$Poliskepticism1), '1:2=1; 3=2; 4:5=3; 6:7=NA') 
data$Poliskpeticism2.d <- recode(as.numeric(ases$Poliskepticism2), '1:2=1; 3=2; 4:5=3; 6:7=NA') 
data$Welfarepride.d <- recode(as.numeric(ases$Welfarepride), '1:2=1; 3:4=2; 5:6=NA') 
data$Economypride.d <- recode(as.numeric(ases$Economypride), '1:2=1; 3:4=2; 5:6=NA') 
data$Influencepride.d <- recode(as.numeric(ases$Influencepride), '1:2=1; 3:4=2; 5:6=NA') 
data$Consumption.d <- recode(as.numeric(ases$Consumption), '1=1; 2=2; 3=3; 4=4; 5:6 = NA')   # categorical
data$Job.d <- recode(as.numeric(ases$Job), '1=1; 2=2; 3=3; 4=4; 5:6 = NA') # categorical
data$Living <- recode(as.numeric(ases$Living), '1=1; 2=2; 3=3; 4=4; 5:6 = NA') # categorical  
data$Inequality.d <- recode(as.numeric(ases$Inequality), '1:2=1; 3=2; 4:5=3; 6:7=NA')
data$Govt.welfare.d <- recode(as.numeric(ases$Govt.welfare), '1:2=1; 3=2; 4:5=3; 6:7=NA')
data$Govtinterven.d <- recode(as.numeric(ases$Govtinterven), '1:2=1; 3=2; 4:5=3; 6:7=NA')
data$Freemarket.d <- recode(as.numeric(ases$Freemarket), '1:2=1; 3=2; 4:5=3; 6:7=NA') 
data$Competition.d <- recode(as.numeric(ases$Competition), '1:2=1; 3=2; 4:5=3; 6:7=NA') 
data$Environ.d <- recode(as.numeric(ases$Environ), '1:2=1; 3=2; 4:5=3; 6:7=NA')  
data$Familyobl.d <- recode(as.numeric(ases$Familyobl), '1:2=1; 3=2; 4:5=3; 6:7=NA')

data$Worryeco.rev <- recode(as.numeric(ases$Worryeco), '1=3; 2=2; 3=1; 4=NA; 5=NA') ## "The economy"
data$Worrycorrupt.rev <- recode(as.numeric(ases$Worrycorrupt), '1=3; 2=2; 3=1; 4=NA; 5=NA') ## "Political corruption"
data$Worryunemploy.rev <- recode(as.numeric(ases$Worryunemploy), '1=3; 2=2; 3=1; 4=NA; 5=NA')  ## "Unemployment"
data$Worrycrime.rev <- recode(as.numeric(ases$Worrycrime), '1=3; 2=2; 3=1; 4=NA; 5=NA') ## "The level of crime"
data$Worryimmig.rev <- recode(as.numeric(ases$Worryimmig), '1=3; 2=2; 3=1; 4=NA; 5=NA')  ## "The level of immigration"
data$Worryenviron.rev <- recode(as.numeric(ases$Worryenviron), '1=3; 2=2; 3=1; 4=NA; 5=NA')  ## "The condition of environment"

### Egocentric Insecurities
data$Worrymywork.rev <- recode(as.numeric(ases$Worrymywork), '1=3; 2=2; 3=1; 4=NA; 5=NA')   ## "Your work situation"
data$Worrymyneighbor.rev <- recode(as.numeric(ases$Worrymyneighbor), '1=3; 2=2; 3=1; 4=NA; 5=NA')  ## "Your neighborhood"
data$Worrymycountry.rev <- recode(as.numeric(ases$Worrymycountry), '1=3; 2=2; 3=1; 4=NA; 5=NA')  ## "Your country"
data$Worryworld.rev <- recode(as.numeric(ases$Worryworld), '1=3; 2=2; 3=1; 4=NA; 5=NA')  ## "The international situation generally"

data$Unfair.d <- recode(as.numeric(ases$Fair), '1=2; 2=2; 3=NA; 4=NA')

write.table(data, file = "asesLarge.txt", sep = " ", na = "NaN",  row.names = FALSE, col.names = TRUE)

