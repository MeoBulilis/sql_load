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
    skills_dim.skills,
    Count(DISTINCT top_paying_jobs.job_id) AS skill_count
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
GROUP BY
    skills_dim.skills
ORDER BY
    skill_count DESC
LIMIT 10;