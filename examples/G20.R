str <- 
"Region	Country	Trade.mil.USD	Nom.GDP.mil.USD	HDI	Population	Economic.classification
Africa	 South Africa	208000	384315	0.629	53000000	Developing
North America	 United States	3969000	15684750	0.937	316173000	Advanced
North America	 Canada	962600	1819081	0.911	34088000	Advanced
North America	 Mexico	756800	1177116	0.775	112211789	Developing
South America	 Brazil	494800	2395968	0.73	201032714	Developing
South America	 Argentina	152690	474954	0.811	40117096	Developing
Asia	 China	3801000	8227037	0.699	1339724852	Developing
Asia	 Japan	1649800	5963969	0.912	127390000	Advanced
Asia	 South Korea	1068700	1155872	0.909	50004441	Advanced
Asia	 India	809400	1824832	0.554	1210193422	Developing
Asia	 Indonesia	384100	878198	0.629	237556363	Developing
Eurasia	 Russia	900600	2021960	0.788	143400000	Developing
Eurasia	 Turkey	370800	794468	0.722	72561312	Developing
Europe	 Germany	2768000	3400579	0.92	81757600	Advanced
Europe	 France	1226400	2608699	0.893	65447374	Advanced
Europe	 United Kingdom	1127000	2440505	0.875	62041708	Advanced
Europe	 Italy	953000	2014079	0.881	60325805	Advanced
Middle East	 Saudi Arabia	518300	727307	0.782	27123977	Developing
Oceania	 Australia	522000	1541797	0.938	22328632	Advanced"
G20 <- read.csv(textConnection(str), header=TRUE, row.names=NULL, sep="\t", check.names=FALSE)
