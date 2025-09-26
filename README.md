# SQL Data Analyst Project

This project is inspired by what I have learned from Luke Barousse’s YouTube video tutorial on SQL for Data Analysts.  
I followed along and practiced writing SQL queries to analyze job postings data, focusing on skills demand and salary insights.  

A big thanks to [Luke Barousse](https://www.youtube.com/@LukeBarousse) for creating and sharing such valuable learning resources!  

📺 YouTube Video: [SQL for Data Analysts | Full Course](https://www.youtube.com/watch?v=7mz73uXD9DA)  
  


# Background
Guided by Luke Barousse’s video, this project was driven by the goal of navigating the data analyst job market more effectively.  
It was designed to pinpoint top-paid and in-demand skills, helping streamline the process of finding optimal jobs.  

The key questions framed in the video and explored through SQL queries were:

- What are the top-paying data analyst jobs?  
- What skills are required for these top-paying jobs?  
- What skills are most in demand for data analysts?  
- Which skills are associated with higher salaries?  
- What are the most optimal skills to learn?  

# Tools Used

- **SQL**: For querying and analyzing job postings data.  
- **Postgres**: The database system used to store and manage the dataset.  
- **VS Code**: As the development environment for writing and testing SQL queries.  
- **Git and GitHub**: For version control and sharing the project.  

# Database Schema

The project is built on a relational database consisting of four main tables:

- **job_postings_fact**: Contains detailed job posting information such as title, location, schedule type, posting date, work-from-home, and salary data.  
- **company_dim**: Stores information about companies, including company id, website links.  
- **skills_job_dim**: Acts as a bridge table linking job postings with specific skills.  
- **skills_dim**: Contains the list of skills (e.g., SQL, Python, Excel) and their associated types.  

These tables are connected through primary and foreign keys to enable efficient querying and analysis of job postings and skill requirements.  

![Database Schema](assets\sql_project_database.png)


# The Analysis

## Query 1: Top-Paying Remote Data Analyst Jobs  

This query answers the question: *What are the top-paying remote Data Analyst jobs?*  

It retrieves the top 10 highest-paying job postings with details such as job title, location, schedule type, posting date, salary, and company name.  
The query filters for Data Analyst roles with a location set to "Anywhere" (remote) and non-null salary values, then orders the results by average yearly salary in descending order.  


```sql
SELECT
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
    name AS company_name
FROM 
    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_title_short = 'Data Analyst' AND
    job_location = 'Anywhere' AND
    salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC
LIMIT 10;
```
- **Mantys** offers the highest-paying position with an average yearly salary of **$650,000**, standing out as an outlier.  
- **Meta** and **AT&T** also rank highly, with salaries of **$336,500** and **$255,829.5**, respectively.  
- Other companies such as **Pinterest**, **Uclahealthcareers**, and **SmartAsset** offer competitive salaries ranging from **$232,000–$205,000**.  
- The remaining roles cluster between **$180,000–$190,000**, reflecting strong opportunities for senior or principal analyst positions.

![average_salary](assets\average_salary_top_paying_jobs.png)
*Bar graph visualizing the average salary for the top 10 salaries for data analysts; the query results were exported into a csv file and the graph was generated through excel*

## Query 2: Skills needed for top paying data analyst jobs
This query answers the question: *What skills are required for these top-paying jobs?*  

```sql
WITH top_paying_jobs AS (
    SELECT
        job_id,
        job_title,
        salary_year_avg,
        name AS company_name
    FROM 
        job_postings_fact
    LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_title_short = 'Data Analyst' AND
        job_location = 'Anywhere' AND
        salary_year_avg IS NOT NULL
    ORDER BY
        salary_year_avg DESC
    LIMIT 10
)

SELECT 
    top_paying_jobs.*,
    skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    salary_year_avg DESC;
```


**SQL** and **Python** dominate the top-paying data roles, appearing in nearly every high-salary job (8 and 7 mentions, respectively). This shows they are considered core, indispensable skills.

**Tableau** appeared 6 times. It's presence shows that data visualization and dashboarding skills are highly valued at the top end of the salary range.

R appears a few times, mostly in roles tied to statistical analysis and marketing analytics.

Specialized tools like Azure, Databricks, and Crystal show up only once, suggesting they are niche requirements depending on company tech stacks.

![skill_count](assets\skill_count_top_paying_jobs.png)
*Bar graph visualizing the skill count for the top paying jobs for data analysts; the query results were exported into a csv file and the graph was generated through excel.*

## Query 3: The most in demand skills for data analysts

This query identifies the top 10 in demand skills for the remote Data Analyst job postings. It filters job listings for Data Analysts with 'Anywhere' as the location, joins them with their associated skills, counts the distinct job postings per skill, and returns the skills ranked by its frequency.

```sql
WITH top_paying_jobs AS (
    SELECT
        job_id,
        job_title
    FROM 
        job_postings_fact
    WHERE
        job_title_short = 'Data Analyst' AND
        job_location = 'Anywhere'
)

SELECT 
    skills_dim.skill,
    Count(DISTINCT top_paying_jobs.job_id) AS skill_count
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
GROUP BY
    skills_dim.skill
ORDER BY
    skill_count DESC;
```
Here are some insights from the most demanded skills for data analyst roles in 2023
- **SQL** dominated with 7,291 mentions, reinforcing its position as the most essential skill for Data Analysts.
- **Excel** remains highly relevant (4,611), showing that traditional tools are still heavily relied upon, even in high-paying roles.
- **Python** (4,330) stands close to Excel, emphasizing the growing demand for programming and automation skills.
- **Tableau** (3,745) and Power BI (2,609) highlight the importance of data visualization and business intelligence tools.
- **R** is present but less common than Python, showing it’s valuable for specific statistical/analytical contexts.
- Tools like SAS, Looker, Azure, and PowerPoint appear less frequently, suggesting they are niche or supplementary skills rather than core requirements.

| Skill       | Skill Count |
|-------------|-------------|
| SQL         | 7,291       |
| Excel       | 4,611       |
| Python      | 4,330       |
| Tableau     | 3,745       |
| Power BI    | 2,609       |
| R           | 2,142       |
| SAS         | 933         |
| Looker      | 868         |
| Azure       | 821         |
| PowerPoint  | 819         |
*Table of the demand for the top 10 skills in data analyst job postings*

## Query 4: Skills associated with higher salaries 
This query identifies the top 25 skills associated with the highest average salaries for remote Data Analyst positions. It joins job postings with their required skills, calculates the average yearly salary for each skill, and orders the results from highest to lowest average salary.

```sql
SELECT 
    skills,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL 
    AND job_work_from_home = TRUE
GROUP BY
    skills_dim.skills
ORDER BY
    avg_salary DESC
LIMIT 25;
```
Insights:

- Big Data & Cloud skills dominate: Tools like PySpark, Databricks, and GCP show very high salary averages, reflecting the growing demand for handling large-scale data and cloud integration.

- Machine Learning & AI tools stand out: Skills such as Watson, DataRobot, scikit-learn, and Airflow highlight the premium on AI/ML proficiency for data analysts.

- Programming & Data Science staples still pay well: Pandas, NumPy, and Jupyter remain core to data workflows and command solid salaries.

- DevOps/Collaboration tools appear unexpectedly: Bitbucket, GitLab, and Jenkins suggest that data analysts with version control and CI/CD knowledge may be positioned for higher-paying, cross-functional roles.

| Skill         | Avg. Salary ($) |
| ------------- | --------------- |
| pyspark       | 208,172         |
| bitbucket     | 189,155         |
| couchbase     | 160,515         |
| watson        | 160,515         |
| datarobot     | 155,486         |
| gitlab        | 154,500         |
| swift         | 153,750         |
| jupyter       | 152,777         |
| pandas        | 151,821         |
| elasticsearch | 145,000         |
| golang        | 145,000         |
| numpy         | 143,513         |
| databricks    | 141,907         |
| linux         | 136,508         |
| kubernetes    | 132,500         |
| atlassian     | 131,162         |
| twilio        | 127,000         |
| airflow       | 126,103         |
| scikit-learn  | 125,781         |
| jenkins       | 125,436         |
| notion        | 125,000         |
| scala         | 124,903         |
| postgresql    | 123,879         |
| gcp           | 122,500         |
| microstrategy | 121,619         |
*Table of the top 25 skills with high average salary*


## Query 5: Most optimal skills to learn for Data Analyst
This query identifies the most optimal skills for data analysts by balancing both **market demand** (number of job postings requiring the skill) and **average salary**. It filters for remote data analyst roles with available salary data, groups results by each skill, and returns the top 25 skills with at least 10 mentions.

```sql
SELECT
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(*) as demand_count,
    ROUND(AVG(salary_year_avg),0) AS average_salary
FROM
    job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_postings_fact.job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = 'TRUE'
GROUP BY
    skills_dim.skill_id,
    skills_dim.skills
HAVING
    COUNT(*) > 10
ORDER BY
    average_salary DESC,
    demand_count DESC
LIMIT 25;
```

- Go (115,320), Confluence (114,210), and Hadoop (113,193) command the highest salaries but have relatively low demand counts compared to mainstream tools. These may represent specialized roles.

- Snowflake, Azure, BigQuery, and AWS all pay well above $108k while also appearing in a fair number of postings, making them strategic choices for analysts wanting to expand into data engineering or cloud-based analytics.

- Foundational skills dominate demand: Python (236 postings, $101k), R (148 postings, $100k), and Tableau (230 postings, $99k) stand out for their sheer demand, even if the salaries are slightly lower than niche tools. These remain core must-have skills for analysts.
- Looker (49 postings, $103k) and Tableau (230 postings, $99k) show the growing importance of BI tools. Analysts proficient in both traditional (SQL, Oracle) and modern BI platforms have broader opportunities.
- Tools like SAS, SQL Server, SSIS, and SSRS still appear with solid demand and decent salaries. These may be particularly relevant in finance, healthcare, and government sectors.

| skill_id | skills     | demand_count | average_salary |
| -------- | ---------- | ------------ | -------------- |
| 8        | go         | 27           | 115,320        |
| 234      | confluence | 11           | 114,210        |
| 97       | hadoop     | 22           | 113,193        |
| 80       | snowflake  | 37           | 112,948        |
| 74       | azure      | 34           | 111,225        |
| 77       | bigquery   | 13           | 109,654        |
| 76       | aws        | 32           | 108,317        |
| 4        | java       | 17           | 106,906        |
| 194      | ssis       | 12           | 106,683        |
| 233      | jira       | 20           | 104,918        |
| 79       | oracle     | 37           | 104,534        |
| 185      | looker     | 49           | 103,795        |
| 2        | nosql      | 13           | 101,414        |
| 1        | python     | 236          | 101,397        |
| 5        | r          | 148          | 100,499        |
| 78       | redshift   | 16           | 99,936         |
| 187      | qlik       | 13           | 99,631         |
| 182      | tableau    | 230          | 99,288         |
| 197      | ssrs       | 14           | 99,171         |
| 92       | spark      | 13           | 99,077         |
| 13       | c++        | 11           | 98,958         |
| 186      | sas        | 63           | 98,902         |
| 61       | sql server |              |                |


# What I learned
Through this tutorial project, I gained valuable experience working with SQL and data analysis. Some of the key takeaways include:

**Database setup and relationships**
- Learned how to structure databases and define relationships between tables to support analysis.

**SQL syntax and query logic**
- Understood the order of operations in SQL queries.
Improved proficiency in writing clean, efficient queries.

**Aggregation techniques**
- Gained experience using functions like COUNT, AVG, SUM, and ROUND to summarize data.

**Subqueries and Common Table Expressions (CTEs)**
- Learned how to break down complex problems into manageable steps using subqueries and CTEs.

**Transforming raw data into insights**
- Developed the ability to take raw, unstructured data and convert it into actionable information that answers meaningful questions.

**Git and GitHub**
- Practiced using Git for version control to track changes and manage project history.
- Learned how to create and organize repositories for structured project management.
- Gained experience publishing projects to GitHub, making them shareable and accessible as portfolio pieces.

**Analytical problem-solving**
- Most importantly, I learned how to approach real-world business questions and use SQL to uncover answers from data.

# Conclusions
This project provided a structured exploration of the Data Analyst job market through SQL analysis. By answering the five guiding questions, several clear takeaways emerged:

- **Top-paying jobs:** Remote Data Analyst roles can offer highly competitive salaries, with outliers (like Mantys at $650k) but most clustering between $180k–$250k for senior positions.

- **Skills required for top-paying jobs:** Core technical skills like **SQL, Python, and Tableau**consistently appear in the highest-paying roles, making them indispensable for analysts seeking top salaries.

- **Most in-demand skills:** SQL dominates the market with overwhelming demand, followed by Excel, Python, and visualization tools like Tableau and Power BI. These remain the foundational skills for employability.

- **Skills associated with higher salaries:** Advanced tools in Big Data (PySpark, Hadoop, Databricks), Cloud (GCP, AWS, Azure), and Machine Learning (scikit-learn, Airflow, Watson, DataRobot) are linked to the highest salaries, indicating specialization pays off.

- **Most optimal skills to learn:** Balancing demand and salary potential, Python, SQL, R, and Tableau remain must-haves, while cloud and data engineering tools like Snowflake, BigQuery, and AWS are excellent additions for long-term career growth.

### Closing Thoughts
This project not only strengthened my SQL skills but also gave me meaningful insights into the Data Analyst job market. By analyzing real-world job postings, I was able to identify the skills that are most valuable, most in demand, and most rewarding in terms of salary. These findings will serve as a roadmap for prioritizing my learning journey, helping me focus on both foundational tools and specialized technologies.

I’m excited to continue exploring the field of data analytics. This project marks just the beginning. It’s the first of many more projects I plan to build, each one pushing me further in transforming raw data into actionable insights.