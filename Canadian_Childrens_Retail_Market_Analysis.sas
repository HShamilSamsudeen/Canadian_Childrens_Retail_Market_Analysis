
libname mylib '/home/u50059513/canadian_children_retail_market_analysis/cleaned_data';

PROC IMPORT DATAFILE = '/home/u50059513/canadian_children_retail_market_analysis/cleaned_data/Census_Age_Location.csv' OUT = mylib.Census_Age_Location 
DBMS = CSV REPLACE;
	getnames = yes;
	guessingrows= max;
RUN;

title "Checking Contents of Census Dataset (Age & Location)";
PROC CONTENTS DATA = mylib.Census_Age_Location;
RUN;

title "Printing out First 10 Observations from Census Dataset (Age & Location) Dataset";
PROC PRINT DATA = mylib.Census_Age_Location (obs = 10);
RUN;

/*Split Into 2011*/
PROC SQL;
	create table mylib.Census_Age_Location2011 as
	select * from mylib.Census_Age_Location where Census_Year = 2011;
QUIT;

title "Printing out First 10 Observations from Census 2011 Dataset (Age & Location) Dataset";
PROC PRINT DATA = mylib.Census_Age_Location2011 (obs = 10);
RUN;

/*Split Into 2016*/
PROC SQL;
	create table mylib.Census_Age_Location2016 as
	select * from mylib.Census_Age_Location where Census_Year = 2016;
QUIT;

title "Printing out First 10 Observations from Census 2016 Dataset (Age & Location) Dataset";
PROC PRINT DATA = mylib.Census_Age_Location2016 (obs = 10);
RUN;

/*
	Objective 1
*/

PROC SQL;
	create table Top10_Cities2011 as 
	select GEO_NAME, SUM(Male_Count) as Male_Total, SUM(Female_Count) as Female_Total, SUM(Total_Count) as Total from
		(select GEO_LEVEL, GEO_NAME, Male_Count, Female_Count, 
		SUM(Male_Count, Female_Count) as Total_Count
		from mylib.Census_Age_Location2011
		where Categories IN ('0 to 4 years', '5 to 9 years', '10 to 14 years') and geo_Level = 2
		)
	group by GEO_NAME
	order by Total DESC;
QUIT;

title "Top 10 Most Populous Cities 2011";
PROC PRINT DATA = Top10_Cities2011 (obs = 10);
	format Male_Total Female_Total Total comma10.;
RUN;

*Export Dataset;
PROC EXPORT 
	data = Top10_Cities2011 
	dbms = xlsx 
	outfile = "/home/u50059513/canadian_children_retail_market_analysis/output_data/Top10_Cities2011.xlsx" 
	replace;
RUN;

PROC SORT DATA = mylib.census_age_location2011 out = mylib.sorted_2011;
	by Categories;
RUN;

PROC MEANS DATA = mylib.sorted_2011 sum noprint;
	var Male_Count Female_Count;
	class GEO_NAME Categories;
	where Categories IN ('0 to 4 years', '5 to 9 years', '10 to 14 years') AND GEO_LEVEL = 2
	AND GEO_NAME IN ('Toronto', 'Montréal', 'Vancouver', 'Calgary', 'Edmonton', 'Ottawa - Gatineau', 'Winnipeg',
					  'Québec', 'Hamilton', 'Kitchener - Cambridge - Waterloo');
	output out = Census_Means_2011 sum= /autoname;
RUN;

DATA Census_Percentage_2011;
	set Census_Means_2011;
	Male_Percentage = Male_Count_Sum/SUM(Male_Count_Sum, Female_Count_Sum);
	Female_Percentage = Female_Count_Sum/SUM(Male_Count_Sum, Female_Count_Sum);
RUN;

title "Census 2011 - Male Female Proportions (0 to 14 Year Olds)";
PROC PRINT DATA = Census_Percentage_2011 (firstobs = 15) noobs;
	var GEO_NAME Categories Male_Count_Sum Female_Count_Sum Male_Percentage Female_Percentage;
	format Male_Percentage Female_Percentage percent8.2;
RUN;

*Export Dataset;
PROC EXPORT 
	data = Census_Percentage_2011 
	dbms = xlsx 
	outfile = "/home/u50059513/canadian_children_retail_market_analysis/output_data/Census_Percentage_2011.xlsx" 
	replace;
RUN;

PROC SQL;
	create table Top10_Cities2016 as 
	select GEO_NAME, SUM(Male_Count) as Male_Total, SUM(Female_Count) as Female_Total, SUM(Total_Count) as Total from
		(select GEO_LEVEL, GEO_NAME, Male_Count, Female_Count, 
		SUM(Male_Count, Female_Count) as Total_Count
		from mylib.Census_Age_Location2016
		where Categories IN ('0 to 4 years', '5 to 9 years', '10 to 14 years') and geo_Level = 2
		)
	group by GEO_NAME
	order by Total DESC;
QUIT;

title "Top 10 Most Populous Cities 2016";
PROC PRINT DATA = Top10_Cities2016 (obs = 10);
	format Male_Total Female_Total Total comma10.;
RUN;

*Export Dataset;
PROC EXPORT 
	data = Top10_Cities2016 
	dbms = xlsx 
	outfile = "/home/u50059513/canadian_children_retail_market_analysis/output_data/Top10_Cities2016.xlsx" 
	replace;
RUN;

PROC SORT DATA = mylib.census_age_location2016 out = mylib.sorted_2016;
	by Categories;
RUN;

PROC MEANS DATA = mylib.sorted_2016 sum noprint;
	var Male_Count Female_Count;
	class GEO_NAME Categories;
	where Categories IN ('0 to 4 years', '5 to 9 years', '10 to 14 years') AND GEO_LEVEL = 2
	AND GEO_NAME IN ('Toronto', 'Montréal', 'Vancouver', 'Calgary', 'Edmonton', 'Ottawa - Gatineau', 'Winnipeg',
					  'Québec', 'Hamilton', 'Kitchener - Cambridge - Waterloo');
	output out = Census_Means_2016 sum= /autoname;
RUN;

DATA Census_Percentage_2016;
	set Census_Means_2016;
	Male_Percentage = Male_Count_Sum/SUM(Male_Count_Sum, Female_Count_Sum);
	Female_Percentage = Female_Count_Sum/SUM(Male_Count_Sum, Female_Count_Sum);
RUN;

title "Census 2016 - Male Female Proportions (0 to 14 Year Olds)";
PROC PRINT DATA = Census_Percentage_2016 (firstobs = 15) noobs;
	var GEO_NAME Categories Male_Count_Sum Female_Count_Sum Male_Percentage Female_Percentage;
	format Male_Percentage Female_Percentage percent8.2;
RUN;

*Export Dataset;
PROC EXPORT 
	data = Census_Percentage_2016 
	dbms = xlsx 
	outfile = "/home/u50059513/canadian_children_retail_market_analysis/output_data/Census_Percentage_2016.xlsx" 
	replace;
RUN;

/*
	Objective 2
*/

DATA mylib.census_age_location2011_renamed;
	set mylib.census_age_location2011;
	rename 'Geo_Code'n= Geo_Code2011
		   'Geo_Name'n= Geo_Name2011
		   'Geo_Level'n= Geo_Level2011
		   'GNR'n= GNR2011
		   'DATA_QUALITY_FLAG'n= Data_Quality_Flag2011
		   'ALT_GEO_CODE'n= Alt_Geo_Code2011
		   'Census_Year'n= Census_Year2011
		   'Categories'n= Categories2011
		   'Age_ID'n= Age_ID2011
		   'Male_Count'n= Male_Count2011
		   'Female_Count'n= Female_Count2011;
RUN;

DATA Merged_2016_2011;
	merge mylib.census_age_location2011_renamed mylib.census_age_location2016;
RUN;


DATA mylib.Yearly_Change;
	set Merged_2016_2011;
	Total_2011 = SUM(Male_Count2011, Female_Count2011);
	Total_2016 = SUM(Male_Count, Female_Count);
	Yearly_Change = ((Total_2016 - Total_2011)/Total_2011);
	format Yearly_Change percent8.2;
RUN;

title "Yearly Change from 2011 to 2016";
PROC PRINT DATA = mylib.Yearly_Change (obs = 30) noobs;
	var GEO_NAME Categories Yearly_Change;
	where GEO_NAME IN ('Toronto', 'Montréal', 'Vancouver', 'Calgary', 'Edmonton', 'Ottawa - Gatineau', 'Winnipeg',
					  'Québec', 'Hamilton', 'Kitchener - Cambridge - Waterloo')
	AND Categories IN ('0 to 4 years', '5 to 9 years', '10 to 14 years')
	AND GEO_LEVEL = 2;
RUN;

PROC SQL outobs=30;
	create table yearly_change_2011_2016 as
	select GEO_NAME, Categories, Yearly_Change
	from mylib.Yearly_Change
	where GEO_NAME IN ('Toronto', 'Montréal', 'Vancouver', 'Calgary', 'Edmonton', 'Ottawa - Gatineau', 'Winnipeg',
					  'Québec', 'Hamilton', 'Kitchener - Cambridge - Waterloo')
	AND Categories IN ('0 to 4 years', '5 to 9 years', '10 to 14 years')
	AND GEO_LEVEL = 2;
RUN;

*Export Dataset;
PROC EXPORT 
	data = yearly_change_2011_2016 
	dbms = xlsx 
	outfile = "/home/u50059513/canadian_children_retail_market_analysis/output_data/yearly_change_2011_2016.xlsx" 
	replace;
RUN;

/*
	Objective 3
*/

PROC IMPORT datafile = '/home/u50059513/canadian_children_retail_market_analysis/cleaned_data/National_Average6006.xlsx' out = national_income 
	dbms=xlsx replace;
	getnames=yes;
RUN;

PROC SQL;
	create table national_median_income_2005 as
	select geo_name, income_source, sex, median_amount_2005 format dollar10.2
	from national_income
	where geo_name IN ('Canada')
	AND sex IN ('Both sexes') 
	order by median_amount_2005 desc;
RUN;

title "Canadian National Median Income (2005)";					  
PROC PRINT DATA = national_median_income_2005;
RUN;

PROC SQL;
	create table national_median_income_2015 as
	select geo_name, income_source, sex, median_amount_2015 format dollar10.2
	from national_income
	where geo_name IN ('Canada')
	AND sex IN ('Both sexes') 
	order by median_amount_2015 desc;
RUN;
				
title "Canadian National Median Income (2015)";
PROC PRINT DATA = national_median_income_2015;
RUN;

*Checking Median Income for Top 10 Prospective Cities;

PROC IMPORT DATAFILE = '/home/u50059513/canadian_children_retail_market_analysis/cleaned_data/CLEANED AFTER TAX INCOME 98-402-X2016006-T2-CSD-Eng.csv'
	out = median_income006 dbms=csv replace;
	getnames=yes;
	guessingrows=max;
RUN;
 
title "Checking Contents of Median Income File";
PROC CONTENTS DATA = median_income006;
RUN;

PROC SQL;
	create table top10_median_income_2005 as
	select metropolitan_area, income_source , gender, median_income_amount_2005 format dollar10.2
	from median_income006
	where metropolitan_area IN ('Toronto', 'Montreal', 'Vancouver', 'Calgary', 'Edmonton','Ottawa', 'Winnipeg',
							  'Quebec', 'Hamilton', 'Kitchener')
	AND Income_source IN ('After-tax income')
	AND gender IN ('Both sexes') 
	order by median_income_amount_2005 desc;
RUN;

title "Median Income for Top 10 Cities (2005)";				  
PROC PRINT DATA = top10_median_income_2005;
RUN;

PROC SQL;
	create table top10_median_income_2015 as
	select metropolitan_area, income_source , gender, median_income_amount_2015 format dollar10.2
	from median_income006
	where metropolitan_area IN ('Toronto', 'Montreal', 'Vancouver', 'Calgary', 'Edmonton','Ottawa', 'Winnipeg',
							  'Quebec', 'Hamilton', 'Kitchener')
	AND Income_source IN ('After-tax income')
	AND gender IN ('Both sexes') 
	order by median_income_amount_2015 desc;
RUN;

title "Median Income for Top 10 Cities (2015)";					  
PROC PRINT DATA = top10_median_income_2015;
RUN;

*Extracting the Max and Min Median Incomes and Range for Top 10 Cities;

PROC SQL;
	create table top10_median_income_maxmin_2005 as
	select *, max(median_income_amount_2005) as max_income, min(median_income_amount_2005) as min_income, 
	(max(median_income_amount_2005)-min(median_income_amount_2005))/3 as range
	from top10_median_income_2005;
RUN;

PROC SQL;
	create table top10_median_income_maxmin_2015 as
	select *, max(median_income_amount_2015) as max_income, min(median_income_amount_2015) as min_income, 
	(max(median_income_amount_2015)-min(median_income_amount_2015))/3 as range
	from top10_median_income_2015;
RUN;

*Classifying Cities into High, Medium, Low Median Income Cities;

title 'Top 10 Cities 2005 Median Income with Classes High, Middle, Low';
DATA top10_median_income_classes_2005;
	set top10_median_income_maxmin_2005;
	format income_class $ char10.;
	IF min_income LE median_income_amount_2005 LT (min_income+range) THEN income_class = 'Low';
	IF (min_income+range) LE median_income_amount_2005 LT (min_income+2*range) THEN income_class = 'Middle';
	IF median_income_amount_2005 GE (min_income+2*range) THEN income_class = 'High';
RUN;

PROC PRINT DATA = top10_median_income_classes_2005;
	var metropolitan_area Income_source gender Median_income_amount_2005 income_class;
RUN;

title 'Top 10 Cities 2015 Median Income with Classes High, Middle, Low';
DATA top10_median_income_classes_2015;
	set top10_median_income_maxmin_2015;
	format income_class $ char10.;
	IF min_income LE median_income_amount_2015 LT (min_income+range) THEN income_class = 'Low';
	IF (min_income+range) LE median_income_amount_2015 LT (min_income+2*range) THEN income_class = 'Middle';
	IF median_income_amount_2015 GE (min_income+2*range) THEN income_class = 'High';
RUN;

PROC PRINT DATA = top10_median_income_classes_2015;
	var metropolitan_area Income_source gender Median_income_amount_2015 income_class;
RUN;

*Looking at Income Sources in Top 10 Cities;
DATA income_source;
	set '/home/u50059513/canadian_children_retail_market_analysis/cleaned_data/income_source.sas7bdat';
RUN;

title "Looking at Major Income Sources for Citites in 2005";
PROC SQL;
	create table top10_income_source_2005 as
	select geo_name, year, age, gender, income_sources_and_taxes, percent_with_amount 
	from income_source
	where geo_name IN ('Toronto','Montréal', 'Vancouver', 'Calgary', 'Edmonton','Ottawa - Gatineau', 'Winnipeg',
					  'Quebec', 'Hamilton', 'Kitchener - Cambridge - Waterloo')
	AND year=2005
	AND age IN ('Total - Age')
	AND gender IN ('Total - Sex') 
	AND income_sources_and_taxes IN ('Employment income','Employment Insurance (EI) benefits') 
	order by percent_with_amount desc;
RUN;

PROC PRINT DATA = top10_income_source_2005;
RUN;

title "Looking at Major Income Sources for Citites in 2015";
PROC SQL;
	create table top10_income_source_2015 as
	select geo_name, year, age, gender, income_sources_and_taxes, percent_with_amount 
	from income_source
	where geo_name IN ('Toronto','Montréal', 'Vancouver', 'Calgary', 'Edmonton','Ottawa - Gatineau', 'Winnipeg',
					  'Quebec', 'Hamilton', 'Kitchener - Cambridge - Waterloo')
	AND year=2015
	AND age IN ('Total - Age')
	AND gender IN ('Total - Sex') 
	AND income_sources_and_taxes IN ('Employment income','Employment Insurance (EI) benefits' ) 
	order by percent_with_amount desc;
RUN;

PROC PRINT DATA = top10_income_source_2015;
RUN;

/*
	Objective 4
*/

PROC IMPORT DATAFILE = '/home/u50059513/canadian_children_retail_market_analysis/cleaned_data/Language_Spoken_Cleaned_6071_v2.xlsx' OUT = mylib.Languages
DBMS = XLSX REPLACE;
	getnames = yes;
RUN;

title "Checking Contents of Language Dataset";
PROC CONTENTS DATA = mylib.Languages;
RUN;

title "First 10 Obs of Language Dataset";
PROC PRINT DATA = mylib.Languages(obs = 10);
RUN;

PROC SQL;
	create table Languages_Spoken as
	select GEO_NAME, Language_Spoken, First_Official_Language_Total,
			English_Count, French_Count, English_and_French_Count, Neither_English_Nor_French_Count, 
			Language_Minority_Count, Language_Minority_Percentage from mylib.Languages
	where DIM_Sex_3 = 'Total - Sex' and DIM_Age_15A = 'Total - Age'
		  and Language_Spoken in ('Cantonese', 'Mandarin', 'Punjabi (Panjabi)', 'Spanish', 'Italian', 'German', 'Arabic'
									'Portuguese', 'Tagalog (Pilipino, Filipino)', 'Urdu')
		  group by Language_Spoken order by First_Official_Language_Total DESC;
QUIT;

PROC SORT DATA = Languages_Spoken out = Languages_Spoken_Sorted;
	by GEO_NAME;
RUN;

PROC SQL;
	create table Top10_Languages_Spoken as
	select GEO_NAME, Language_Spoken, First_Official_Language_Total
	from Languages_Spoken_Sorted;
RUN;

title "Top 10 Languages for Each City";
PROC PRINT DATA = Top10_Languages_Spoken;
RUN;

*Export Dataset;
PROC EXPORT 
	data = Top10_Languages_Spoken
	dbms = xlsx 
	outfile = "/home/u50059513/canadian_children_retail_market_analysis/output_data/Top10_Languages_Spoken.xlsx" 
	replace;
RUN;

/*
	Objective 5
*/

title "Top 10 Most Populous Cities 2016 - for 15-19 years Age Group";
PROC SQL;
	create table Top10_Cities2016_15to19 as 
	select GEO_NAME, SUM(Male_Count) as Male_Total, SUM(Female_Count) as Female_Total, SUM(Total_Count) as Total from
		(select GEO_LEVEL, GEO_NAME, Male_Count, Female_Count, 
		SUM(Male_Count, Female_Count) as Total_Count
		from mylib.Census_Age_Location2016
		where Categories IN ('15 to 19 years') and geo_Level = 2
		)
	group by GEO_NAME
	order by Total DESC;
QUIT;

PROC PRINT DATA = Top10_Cities2016_15to19 (obs = 10);
	format Male_Total Female_Total Total comma10.;
RUN;

*Export Dataset;
PROC EXPORT 
	data = Top10_Cities2016_15to19 
	dbms = xlsx 
	outfile = "/home/u50059513/canadian_children_retail_market_analysis/output_data/Top10_Cities2016_15to19.xlsx" 
	replace;
RUN;

title "Top 10 Most Populous Cities 2016 - for 0-14 years Age Groups";
PROC PRINT DATA = Top10_Cities2016 (obs = 10);
	format Male_Total Female_Total Total comma10.;
RUN;


PROC MEANS DATA = mylib.sorted_2016 sum noprint;
	var Male_Count Female_Count;
	class GEO_NAME Categories;
	where Categories IN ('0 to 4 years', '5 to 9 years', '10 to 14 years', '15 to 19 years') AND GEO_LEVEL = 2
	AND GEO_NAME IN ('Toronto', 'Montréal', 'Vancouver', 'Calgary', 'Edmonton', 'Ottawa - Gatineau', 'Winnipeg',
					  'Québec', 'Hamilton', 'Kitchener - Cambridge - Waterloo');
	output out = Census_Means_0to19 sum= /autoname;
RUN;

DATA Census_Percentage_0to19;
	set Census_Means_0to19;
	Total = SUM(Male_Count_Sum, Female_Count_Sum);
	format Total comma10.;
RUN;

title "Census 2016 - Totals (0 to 19 Year Olds)";
PROC PRINT DATA = Census_Percentage_0to19 (firstobs = 16);
	var GEO_NAME Categories Male_Count_Sum Female_Count_Sum Total;
RUN;

*Export Dataset;
PROC EXPORT 
	data = Census_Percentage_0to19 
	dbms = xlsx 
	outfile = "/home/u50059513/canadian_children_retail_market_analysis/output_data/Census_Percentage_0to19.xlsx" 
	replace;
RUN;