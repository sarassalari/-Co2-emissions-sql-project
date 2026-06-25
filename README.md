{\rtf1\ansi\ansicpg1252\cocoartf2709
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Arial-BoldMT;\f1\fswiss\fcharset0 ArialMT;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\deftab560
\pard\pardeftab560\slleading20\partightenfactor0

\f0\b\fs26 \cf0 CO2 Emissions Data Cleaning Project\
\
\pard\pardeftab560\slleading20\partightenfactor0

\f1\b0 \cf0 This project takes messy raw data on CO2 emissions from different energy \
sources and cleans it using a MySQL database I built from scratch.\
\pard\pardeftab560\slleading20\partightenfactor0

\f0\b \cf0 \
Problems found in the raw data\
\
Problem 1: 
\f1\b0 Fake "13th month" rows\
The data covered 50 years of monthly CO2 emissions. Each date was stored \
as a number like 197101, where 01 meant January. Every year also had an \
extra "month" that was actually the year's total emissions, not a real \
month, so I had to remove those before doing any analysis.
\f0\b \
\
Problem 2: 
\f1\b0 Missing values stored as text\
Some months didn't have a recorded value, and instead of being blank, \
the file had the word "Not Available" written in there. This meant the \
value column couldn't be a number type at first, it had to be text, so \
the import wouldn't crash, and I converted those into proper empty \
values (NULL) during cleaning.
\f0\b \
\
Key findings\
\
\pard\pardeftab560\slleading20\partightenfactor0

\f1\b0 \cf0 1. Coal produces far more CO2 than any other source, about 6 times \
   more than natural gas.\
2. Coal emissions rose for decades, then started decreasing around 2008.\
3. Fossil fuels produced about 298 times more CO2 than the low-carbon \
   sources (geothermal and waste) in this dataset (87,043.7 vs 291.9 \
   million metric tons).}