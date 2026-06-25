CO2 Emissions Data Cleaning Project

This project takes messy raw data on CO2 emissions from different energy 
sources and cleans it using a MySQL database I built from scratch.

Problems found in the raw data

Problem 1: Fake "13th month" rows**
The data covered 50 years of monthly CO2 emissions. Each date was stored 
as a number like 197101, where 01 meant January. Every year also had an 
extra "month" that was actually the year's total emissions, not a real 
month, so I had to remove those before doing any analysis.

Problem 2: Missing values stored as text**
Some months didn't have a recorded value, and instead of being blank, 
the file had the word "Not Available" written in there. This meant the 
value column couldn't be a number type at first, it had to be text, so 
the import wouldn't crash, and I converted those into proper empty 
values (NULL) during cleaning.

Key findings

1. Coal produces far more CO2 than any other source, about 6 times 
   more than natural gas.
2. Coal emissions rose for decades, then started decreasing around 2008.
3. Fossil fuels produced about 298 times more CO2 than the low-carbon 
   sources (geothermal and waste) in this dataset (87,043.7 vs 291.9 
   million metric tons).
