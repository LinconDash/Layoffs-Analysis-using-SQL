# Data Cleaning and Analysis using SQL
## Overview
This project demonstrates techniques such as data cleaning as well as exploratory data analysis using SQL.
- Data cleaning is an essential step in the data analysis process, ensuring that your data is accurate, consistent, and usable for analysis.
- Exploratory data analysis is the process of analysing the dataset thoroughly to find some possible answers to the questions related to dataset.

In this project, we will use SQL to clean a dataset by handling missing values, correcting data types, removing duplicates, and standardizing data formats, then we will perform some queries related to the EDA process to gain some insights based on the cleaned data.
The goal of this project is to transform raw data into a clean, analyzable format and to extract meaningful insights through various SQL queries and techniques.

## Objectives
- Understand and apply data cleaning techniques using SQL.
- Learn how to handle missing values, outliers, and inconsistencies in a dataset.
- Practice converting data types, normalizing data, and ensuring data integrity.
- Use some complex queries to calculate some of the key metrics that are interesting to look at.
- Perform exploratory data analysis to uncover patterns, trends, and insights related to company layoffs.

## Table of Contents
- [Overview](#overview)
- [Objectives](#objectives)
- [Dataset](#dataset)
- [Technologies Used](#technologies-used)
- [Data Cleaning Process](#data-cleaning-process)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Results and Insights](#results-and-insights)
- [How to Run](#how-to-run)
- [Contributing](#contributing)
- [License](#license)

## Dataset
The dataset used in this project is the `Layoffs Dataset`. It includes information about company layoffs, such as the company name, industry, number of layoffs, and the date of the layoffs. The dataset contains around 2600 rows and 9 columns.
The columns are :
- company
- location
- industry
- date
- total_laid_off
- percent_laid_off
- stage
- funds_raised_in_millions
- country

Its already present in the path `Data/layoffs.csv` so you can get access to the data. \
This data is sourced from "Kaggle" platform.

## Technologies Used
- MySQL version 8
- MySQL Workbench

Download the MySQl workbench directly from this <a href="https://www.mysql.com/products/workbench/">link</a>.

## Data Cleaning Process
First create a database in the workbench where you want to perform all the queries \
The data cleaning process involved the following steps:
1. Data Import: Importing the raw data from layoffs.csv with the help of a tool called `Table data Import Wizard` into the preferred SQL database. Doing this will automatically create schema and records of the table from the csv file. 

2. Data Deduplication / Removing duplicate records : It is very important to identify the duplicate records first. There were some duplicate records already present in the dataset, so various techniques of SQL such as CTE, Subqueries and Window function were used to remove the duplicate records. 

3. Data Transformation: Converting data types and normalizing data is an important step of data cleaning and analysis process. All the different columns were inspected one by one and converted to its correct datatype whichever was required. Some columns also contained unrecognized characters so it was corrected using the `regexp` feature function of MySQL  

4. Handling Missing Values: There were many columns such as `total_laid_off`, `percent_laid_off` and `funds_raised_in_millions` which had many null records and therefore all of them were deleted as those columns are important ones and we had this big chunk of waste data which was meaningless. 

5. Data Validation: Validation of  the cleaned data was done due to the risk of potential faults during the data cleaning process. 

## Exploratory Data Analysis
EDA involved using SQL queries to:
- Summarize data through descriptive statistics.
- Identify relationships and correlations between variables such as industry and the number of layoffs.
- Discover any anomalies or patterns in the data.

These are multiple questions that was answered using the SQL queries :
1. Which companies have the highest number of total layoffs?
2. How does the total number of layoffs vary by industry?
3. What is the distribution of layoffs by country?
4. How does the percentage of layoffs compare across different locations?
5. Are there specific months or periods where layoffs were more common?
6. How do layoffs differ between companies in the same industry but in different countries?
7. Which industries have the highest average percentage of layoffs?
8. How do the number of layoffs correlate with the company’s location?
9. Are there any patterns in layoffs based on the company's stage (e.g., Series B, Post-IPO)

and many more.

## Results and Insights
All the results and insights are written as a funny comment below each question query. \
There are many interesting results from the exploratory data analysis as follows :
- Most of the MMANG companies (Meta, Microsoft, Google, Amazon) has highest no. of total layoffs from the year 2021 to 2023.
- United States and India are at top countries where layoffs happened the most.
- Around **66.87 %** of the world layoffs is alone from United States.
- Around **32.74 %** of the world layoffs is alone from SF Bay Area.
- Most common month where layoffs happened the most is **January**.
- `Retail` and `Consumer` industries has highest layoffs.

and many more key findings. 

## How to Run
To run this project locally, you need to have a SQL database set up (e.g., MySQL, PostgreSQL). Follow these steps:

1. Clone the repository:
``` bash
git clone https://github.com/LinconDash/Data-Cleaning-and-Analysis-SQL
cd Data-Cleaning-and-Analysis-SQL
```
2. Import the dataset into your SQL database.
3. Execute the SQL scripts:
- `data_cleaning.sql`: For cleaning the raw data and exporting the cleaned data with the help of `Table data Export Wizard`.
- `exploratory_data_analysis.sql`: For performing exploratory data analysis.

## Contributing
Contributions are welcome! Please adhere to the following guidelines when contributing to this project:

1. Fork the Repository:
- Click on the "Fork" button at the top right corner of the repository page.

2. Clone Your Forked Repository:
``` bash
git clone https://github.com/LinconDash/Data-Cleaning-and-Analysis-SQL
cd Data-Cleaning-and-Analysis-SQL
```

3. Create a New Branch:
- Use a descriptive name for your branch (e.g., feature-add-new-analysis, bugfix-fix-sql-query).
``` bash
git checkout -b your-branch-name
```

4. Make Your Changes:
- Ensure your code follows the project’s coding standards.
- Test your changes thoroughly.

5. Commit Your Changes:
- Write clear and concise commit messages.
``` sh
git commit -m "Description of the changes made"
```

6. Push to Your Forked Repository:
``` sh
git push -u origin your-branch-name
```

7. Create a Pull Request:
- Go to the original repository on GitHub.
- Click on "Pull Requests" and then "New Pull Request."
- Select your branch from the "compare" dropdown and the master branch from the "base" dropdown.
- Provide a clear description of your changes and submit the pull request.

8. Code Review:
- Be open to feedback and make necessary changes if requested by the project maintainer i.e me :)

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
