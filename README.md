# Linux_Bash_Project
## Description 
The project was written as part of the subject of Unix System Data Processing, under the Linux operating system in the VIM text editor.

It splits the data files in .csv format (in this case, meteorological data) and analyzes them. The data comes from the website [IMGW](https://danepubliczne.imgw.pl/data/dane_pomiarowo_obserwacyjne/dane_meteorologiczne/dobowe/opad/). Each line from the files is placed in the appropriate directory depending on the month and day of the measurement. Rows with erroneous measurements are moved to a separate file. Symbolic links are created to files with the highest and lowest daily precipitation totals. The time of the script in milliseconds, PIDs, PPIDs and the command line name of running the script were written to the out.log file.

## Technologies
Project is created with:
* Slackware 15.0
* Bash 5.2.15

## Setup
We run the project according to the scheme:

./projekt2022.sh <base_dir> <data_file_1> <data_file_2> ... <data_file_n>

where

<base_dir> - is the name of the directory where you want to save the result of the action.

<data_file_1> <data_file_2> ... <data_file_n> - is the n paths to the data files.

For example

```
./projekt2022.sh DIR dane/f1 od 02_2021.csv dane/fragm2 2021 2022.csv dane/fragment o_d_02_2021.csv
```

## Testing
Running the test script:

```
cd tester
./tester.sh ../projekt2022.sh
```
All tests passed.
