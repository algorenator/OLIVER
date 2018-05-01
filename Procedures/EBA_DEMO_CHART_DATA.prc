--
-- EBA_DEMO_CHART_DATA  (Procedure) 
--
CREATE OR REPLACE PROCEDURE OLIVER.EBA_DEMO_CHART_DATA AS
    L_OPEN     NUMBER;
    L_CLOSE    NUMBER;
    L_HIGH     NUMBER;
    L_LOW      NUMBER;
    L_VOLUME   NUMBER;
BEGIN
    DELETE FROM EBA_DEMO_CHART_PROJECTS;

    DELETE FROM EBA_DEMO_CHART_TASKS;

    DELETE FROM EBA_DEMO_CHART_POPULATION;

    DELETE FROM EBA_DEMO_CHART_EMP;

    DELETE FROM EBA_DEMO_CHART_DEPT;

    DELETE FROM EBA_DEMO_CHART_BBALL;

    DELETE FROM EBA_DEMO_CHART_ORDERS;

    DELETE FROM EBA_DEMO_CHART_PRODUCTS;

    DELETE FROM EBA_DEMO_CHART_STATS;

    DELETE FROM EBA_DEMO_CHART_STOCKS;
/* Charts Projects Table Data */

    INSERT INTO EBA_DEMO_CHART_PROJECTS (
        ID,
        PROJECT,
        CREATED,
        CREATED_BY
    ) VALUES (
        1,
        'Maintain Support Systems',
        TO_DATE('01-11-2011','DD-MM-YYYY'),
        TO_DATE('30-12-2011','DD-MM-YYYY')
    );

    INSERT INTO EBA_DEMO_CHART_PROJECTS (
        ID,
        PROJECT,
        CREATED,
        CREATED_BY
    ) VALUES (
        2,
        'Load Software',
        TO_DATE('03-12-2011','DD-MM-YYYY'),
        TO_DATE('10-12-2011','DD-MM-YYYY')
    );

    INSERT INTO EBA_DEMO_CHART_PROJECTS (
        ID,
        PROJECT,
        CREATED,
        CREATED_BY
    ) VALUES (
        3,
        'Email Integration',
        TO_DATE('12-01-2012','DD-MM-YYYY'),
        TO_DATE('17-02-2012','DD-MM-YYYY')
    );

    INSERT INTO EBA_DEMO_CHART_PROJECTS (
        ID,
        PROJECT,
        CREATED,
        CREATED_BY
    ) VALUES (
        4,
        'Documentation',
        TO_DATE('19-11-2011','DD-MM-YYYY'),
        TO_DATE('25-11-2011','DD-MM-YYYY')
    );

    INSERT INTO EBA_DEMO_CHART_PROJECTS (
        ID,
        PROJECT,
        CREATED,
        CREATED_BY
    ) VALUES (
        5,
        'Training',
        TO_DATE('01-12-2011','DD-MM-YYYY'),
        TO_DATE('08-12-2011','DD-MM-YYYY')
    );

    INSERT INTO EBA_DEMO_CHART_PROJECTS (
        ID,
        PROJECT,
        CREATED,
        CREATED_BY
    ) VALUES (
        6,
        'Bug Tracker',
        TO_DATE('16-12-2011','DD-MM-YYYY'),
        TO_DATE('19-01-2012','DD-MM-YYYY')
    );

    INSERT INTO EBA_DEMO_CHART_PROJECTS (
        ID,
        PROJECT,
        CREATED,
        CREATED_BY
    ) VALUES (
        7,
        'Migrate Old Systems',
        TO_DATE('28-12-2011','DD-MM-YYYY'),
        TO_DATE('22-02-2012','DD-MM-YYYY')
    );

    INSERT INTO EBA_DEMO_CHART_PROJECTS (
        ID,
        PROJECT,
        CREATED,
        CREATED_BY
    ) VALUES (
        8,
        'Software Projects Tracking',
        TO_DATE('15-12-2012','DD-MM-YYYY'),
        TO_DATE('20-01-2012','DD-MM-YYYY')
    );

    INSERT INTO EBA_DEMO_CHART_PROJECTS (
        ID,
        PROJECT,
        CREATED,
        CREATED_BY
    ) VALUES (
        9,
        'Public Website',
        TO_DATE('06-12-2011','DD-MM-YYYY'),
        TO_DATE('09-12-2011','DD-MM-YYYY')
    );

    INSERT INTO EBA_DEMO_CHART_PROJECTS (
        ID,
        PROJECT,
        CREATED,
        CREATED_BY
    ) VALUES (
        10,
        'Early Adopter Release',
        TO_DATE('05-12-2011','DD-MM-YYYY'),
        TO_DATE('06-02-2012','DD-MM-YYYY')
    );

    INSERT INTO EBA_DEMO_CHART_PROJECTS (
        ID,
        PROJECT,
        CREATED,
        CREATED_BY
    ) VALUES (
        11,
        'Environment Configuration',
        TO_DATE('01-11-2011','DD-MM-YYYY'),
        TO_DATE('22-11-2011','DD-MM-YYYY')
    );

    INSERT INTO EBA_DEMO_CHART_PROJECTS (
        ID,
        PROJECT,
        CREATED,
        CREATED_BY
    ) VALUES (
        12,
        'Customer Satisfaction Survey',
        TO_DATE('18-12-2011','DD-MM-YYYY'),
        TO_DATE('01-01-2011','DD-MM-YYYY')
    );

    INSERT INTO EBA_DEMO_CHART_PROJECTS (
        ID,
        PROJECT,
        CREATED,
        CREATED_BY
    ) VALUES (
        13,
        'Convert Excel Spreadsheet',
        TO_DATE('15-12-2011','DD-MM-YYYY'),
        TO_DATE('15-03-2012','DD-MM-YYYY')
    );

    INSERT INTO EBA_DEMO_CHART_PROJECTS (
        ID,
        PROJECT,
        CREATED,
        CREATED_BY
    ) VALUES (
        14,
        'Upgrade Equipment',
        TO_DATE('01-02-2012','DD-MM-YYYY'),
        TO_DATE('30-05-2012','DD-MM-YYYY')
    );
    
/* Charts Tasks Table Data */

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        74,
        14,
        'Decommission servers',
        TO_DATE('01-02-12','DD-MM-RR'),
        TO_DATE('30-04-12','DD-MM-RR'),
        'Pending',
        'Al Bines',
        0,
        500,
        NULL
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        75,
        6,
        'Measure effectiveness of improved QA',
        TO_DATE('01-02-12','DD-MM-RR'),
        TO_DATE('02-03-12','DD-MM-RR'),
        'Pending',
        'Myra Sutcliff',
        0,
        1500,
        18
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        76,
        10,
        'Response to Customer Feedback',
        TO_DATE('01-02-12','DD-MM-RR'),
        TO_DATE('25-05-12','DD-MM-RR'),
        'Pending',
        'Russ Saunders',
        0,
        6000,
        33
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        77,
        10,
        'User acceptance testing',
        TO_DATE('16-02-12','DD-MM-RR'),
        TO_DATE('20-05-12','DD-MM-RR'),
        'Pending',
        'Russ Saunders',
        0,
        2500,
        33
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        78,
        10,
        'End-user Training',
        TO_DATE('20-03-12','DD-MM-RR'),
        TO_DATE('01-06-12','DD-MM-RR'),
        'Pending',
        'Myra Sutcliff',
        0,
        2500,
        79
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        79,
        10,
        'Rollout sample applications',
        TO_DATE('23-05-12','DD-MM-RR'),
        TO_DATE('03-06-12','DD-MM-RR'),
        'Pending',
        'Pam King',
        0,
        500,
        32
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        72,
        14,
        'Installation',
        TO_DATE('03-02-12','DD-MM-RR'),
        TO_DATE('04-03-12','DD-MM-RR'),
        'Pending',
        'Mark Nile',
        0,
        1500,
        67
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        73,
        14,
        'Notify users',
        TO_DATE('06-03-12','DD-MM-RR'),
        TO_DATE('09-03-12','DD-MM-RR'),
        'Pending',
        'Mark Nile',
        0,
        200,
        67
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        34,
        10,
        'Plan production release schedule',
        TO_DATE('22-12-11','DD-MM-RR'),
        TO_DATE('22-12-11','DD-MM-RR'),
        'Closed',
        'Pam King',
        100,
        100,
        32
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        37,
        12,
        'Complete questionnaire',
        TO_DATE('18-12-11','DD-MM-RR'),
        TO_DATE('01-01-11','DD-MM-RR'),
        'On-Hold',
        'Irene Jones',
        1200,
        800,
        38
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        59,
        11,
        'Select servers for Development, Test, Production',
        TO_DATE('03-11-11','DD-MM-RR'),
        TO_DATE('08-11-11','DD-MM-RR'),
        'Closed',
        'James Cassidy',
        200,
        600,
        61
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        3,
        1,
        'HR Support Systems',
        TO_DATE('01-11-11','DD-MM-RR'),
        TO_DATE('12-03-12','DD-MM-RR'),
        'Closed',
        'Al Bines',
        300,
        500,
        NULL
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        1,
        1,
        'HR software upgrades',
        TO_DATE('01-11-11','DD-MM-RR'),
        TO_DATE('27-02-12','DD-MM-RR'),
        'On-Hold',
        'Pam King',
        8000,
        7000,
        3
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        2,
        1,
        'Arrange for vacation coverage',
        TO_DATE('01-11-11','DD-MM-RR'),
        TO_DATE('31-12-11','DD-MM-RR'),
        'On-Hold',
        'Russ Sanders',
        9500,
        7000,
        3
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        4,
        3,
        'Complete plan',
        TO_DATE('08-11-11','DD-MM-RR'),
        TO_DATE('14-12-11','DD-MM-RR'),
        'Closed',
        'Mark Nile',
        3000,
        1500,
        44
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        5,
        3,
        'Check software licenses',
        TO_DATE('12-12-11','DD-MM-RR'),
        TO_DATE('13-12-11','DD-MM-RR'),
        'Closed',
        'Mark Nile',
        200,
        200,
        44
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        6,
        5,
        'Create training workspace',
        TO_DATE('01-12-11','DD-MM-RR'),
        TO_DATE('08-12-11','DD-MM-RR'),
        'Closed',
        'James Cassidy',
        500,
        700,
        36
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        7,
        5,
        'Publish links to self-study courses',
        TO_DATE('01-12-11','DD-MM-RR'),
        TO_DATE('01-12-11','DD-MM-RR'),
        'Closed',
        'John Watson',
        100,
        100,
        36
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        8,
        2,
        'Identify point solutions required',
        TO_DATE('03-12-11','DD-MM-RR'),
        TO_DATE('05-12-11','DD-MM-RR'),
        'Closed',
        'John Watson',
        200,
        300,
        49
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        9,
        2,
        'Install in development',
        TO_DATE('07-12-11','DD-MM-RR'),
        TO_DATE('07-12-11','DD-MM-RR'),
        'Closed',
        'John Watson',
        100,
        100,
        49
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        15,
        4,
        'Identify owners',
        TO_DATE('19-11-11','DD-MM-RR'),
        TO_DATE('22-11-11','DD-MM-RR'),
        'Closed',
        'Hank Davis',
        250,
        300,
        17
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        16,
        4,
        'Initial Draft Review',
        TO_DATE('23-11-11','DD-MM-RR'),
        TO_DATE('23-11-11','DD-MM-RR'),
        'Closed',
        'Hank Davis',
        100,
        100,
        17
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        17,
        4,
        'Monitor Review Comments',
        TO_DATE('23-11-11','DD-MM-RR'),
        TO_DATE('31-12-11','DD-MM-RR'),
        'Closed',
        'Hank Davis',
        450,
        500,
        NULL
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        18,
        6,
        'Implement bug tracking software',
        TO_DATE('15-11-11','DD-MM-RR'),
        TO_DATE('15-11-11','DD-MM-RR'),
        'Closed',
        'Myra Sutcliff',
        100,
        100,
        NULL
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        19,
        6,
        'Review automated testing tools',
        TO_DATE('16-11-11','DD-MM-RR'),
        TO_DATE('15-12-11','DD-MM-RR'),
        'Closed',
        'Myra Sutcliff',
        2750,
        1500,
        18
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        20,
        7,
        'Identify pilot applications',
        TO_DATE('10-11-11','DD-MM-RR'),
        TO_DATE('15-11-11','DD-MM-RR'),
        'Closed',
        'Mark Nile',
        300,
        500,
        53
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        21,
        7,
        'Migrate pilot applications to ',
        TO_DATE('20-11-11','DD-MM-RR'),
        TO_DATE('25-11-11','DD-MM-RR'),
        'Closed',
        'Mark Nile',
        500,
        500,
        53
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        22,
        8,
        'Customize Software Projects software',
        TO_DATE('15-12-12','DD-MM-RR'),
        TO_DATE('20-01-12','DD-MM-RR'),
        'Open',
        'Tom Suess',
        600,
        1000,
        28
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        23,
        7,
        'Post-migration review',
        TO_DATE('01-12-11','DD-MM-RR'),
        TO_DATE('01-12-11','DD-MM-RR'),
        'Closed',
        'Mark Nile',
        100,
        100,
        53
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        24,
        7,
        'User acceptance testing',
        TO_DATE('03-12-11','DD-MM-RR'),
        TO_DATE('04-12-11','DD-MM-RR'),
        'Closed',
        'Mark Nile',
        600,
        200,
        23
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        25,
        8,
        'Enter base data (Projects, Milestones, etc.)',
        TO_DATE('10-12-11','DD-MM-RR'),
        TO_DATE('11-12-11','DD-MM-RR'),
        'Closed',
        'Tom Suess',
        200,
        200,
        28
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        26,
        8,
        'Load current tasks and enhancements',
        TO_DATE('12-12-11','DD-MM-RR'),
        TO_DATE('16-12-11','DD-MM-RR'),
        'Closed',
        'Tom Suess',
        400,
        500,
        28
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        27,
        6,
        'Document quality assurance procedures',
        TO_DATE('16-12-11','DD-MM-RR'),
        TO_DATE('19-01-12','DD-MM-RR'),
        'On-Hold',
        'Myra Sutcliff',
        3500,
        4000,
        18
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        28,
        8,
        'Conduct project kickoff meeting',
        TO_DATE('05-12-11','DD-MM-RR'),
        TO_DATE('05-12-11','DD-MM-RR'),
        'Closed',
        'Pam King',
        100,
        100,
        NULL
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        29,
        9,
        'Determine host server',
        TO_DATE('06-12-11','DD-MM-RR'),
        TO_DATE('07-12-11','DD-MM-RR'),
        'Closed',
        'Tiger Scott',
        200,
        200,
        40
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        30,
        9,
        'Check software licenses',
        TO_DATE('07-12-11','DD-MM-RR'),
        TO_DATE('07-12-11','DD-MM-RR'),
        'Closed',
        'Tom Suess',
        100,
        100,
        40
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        31,
        10,
        'Identify pilot users',
        TO_DATE('05-12-11','DD-MM-RR'),
        TO_DATE('06-12-11','DD-MM-RR'),
        'Closed',
        'Scott Spencer',
        200,
        200,
        33
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        32,
        10,
        'Software Deliverable',
        TO_DATE('07-12-11','DD-MM-RR'),
        TO_DATE('20-12-11','DD-MM-RR'),
        'Closed',
        'Scott Spencer',
        400,
        500,
        33
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        33,
        10,
        'Early Adopter Release',
        TO_DATE('21-12-11','DD-MM-RR'),
        TO_DATE('21-12-11','DD-MM-RR'),
        'Closed',
        'Pam King',
        100,
        100,
        NULL
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        35,
        11,
        'Determine midtier configuration(s)',
        TO_DATE('02-11-11','DD-MM-RR'),
        TO_DATE('02-11-11','DD-MM-RR'),
        'Closed',
        'James Cassidy',
        100,
        100,
        61
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        36,
        5,
        'Manage Training Activities',
        TO_DATE('28-11-11','DD-MM-RR'),
        TO_DATE('03-02-12','DD-MM-RR'),
        'On-Hold',
        'John Watson',
        1000,
        2000,
        NULL
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        38,
        12,
        'Review feedback',
        TO_DATE('09-01-12','DD-MM-RR'),
        TO_DATE('15-01-12','DD-MM-RR'),
        'On-Hold',
        'Irene Jones',
        200,
        400,
        NULL
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        39,
        12,
        'Plan rollout schedule',
        TO_DATE('16-01-12','DD-MM-RR'),
        TO_DATE('24-01-12','DD-MM-RR'),
        'On-Hold',
        'Irene Jones',
        0,
        750,
        38
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        40,
        9,
        'Plan rollout schedule',
        TO_DATE('10-12-11','DD-MM-RR'),
        TO_DATE('02-01-12','DD-MM-RR'),
        'On-Hold',
        'Al Bines',
        300,
        1000,
        NULL
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        41,
        9,
        'Develop web pages',
        TO_DATE('10-01-12','DD-MM-RR'),
        TO_DATE('15-02-12','DD-MM-RR'),
        'On-Hold',
        'Tiger Scott',
        800,
        2000,
        40
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        42,
        9,
        'Purchase additional software licenses, if needed',
        TO_DATE('17-02-12','DD-MM-RR'),
        TO_DATE('17-02-12','DD-MM-RR'),
        'On-Hold',
        'Tom Suess',
        0,
        100,
        40
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        43,
        1,
        'Investigate new Virus Protection software',
        TO_DATE('29-12-11','DD-MM-RR'),
        TO_DATE('13-01-12','DD-MM-RR'),
        'Open',
        'Pam King',
        1700,
        1500,
        3
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        44,
        3,
        'Get RFPs for new server',
        TO_DATE('13-12-11','DD-MM-RR'),
        TO_DATE('03-01-12','DD-MM-RR'),
        'Open',
        'Mark Nile',
        2000,
        1000,
        NULL
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        45,
        13,
        'Collect mission-critical spreadsheets',
        TO_DATE('15-12-11','DD-MM-RR'),
        TO_DATE('15-02-12','DD-MM-RR'),
        'Open',
        'Pam King',
        2500,
        4000,
        46
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        46,
        13,
        'Create  applications from spreadsheets',
        TO_DATE('15-12-11','DD-MM-RR'),
        TO_DATE('30-05-12','DD-MM-RR'),
        'Open',
        'Pam King',
        6000,
        10000,
        NULL
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        47,
        13,
        'Lock spreadsheets',
        TO_DATE('15-12-11','DD-MM-RR'),
        TO_DATE('30-05-12','DD-MM-RR'),
        'Open',
        'Pam King',
        1000,
        800,
        46
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        48,
        13,
        'Send links to previous spreadsheet owners',
        TO_DATE('16-12-11','DD-MM-RR'),
        TO_DATE('01-06-12','DD-MM-RR'),
        'Open',
        'Pam King',
        1000,
        1500,
        46
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        49,
        2,
        'Customize solutions',
        TO_DATE('08-12-11','DD-MM-RR'),
        TO_DATE('01-03-12','DD-MM-RR'),
        'Open',
        'John Watson',
        1500,
        4000,
        NULL
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        50,
        2,
        'Train developers / users',
        TO_DATE('10-01-12','DD-MM-RR'),
        TO_DATE('25-03-12','DD-MM-RR'),
        'Pending',
        'John Watson',
        0,
        8000,
        49
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        51,
        2,
        'Implement in Production',
        TO_DATE('27-12-11','DD-MM-RR'),
        TO_DATE('03-05-12','DD-MM-RR'),
        'Open',
        'John Watson',
        200,
        1500,
        49
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        52,
        7,
        'Migrate applications',
        TO_DATE('15-12-11','DD-MM-RR'),
        TO_DATE('20-02-12','DD-MM-RR'),
        'Open',
        'Mark Nile',
        1000,
        8000,
        53
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        53,
        7,
        'Plan migration schedule',
        TO_DATE('22-12-11','DD-MM-RR'),
        TO_DATE('03-03-12','DD-MM-RR'),
        'Open',
        'Mark Nile',
        1500,
        6000,
        NULL
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        54,
        10,
        'Publish Feedback application',
        TO_DATE('26-12-11','DD-MM-RR'),
        TO_DATE('04-05-12','DD-MM-RR'),
        'Open',
        'Pam King',
        300,
        12000,
        33
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        55,
        6,
        'Train developers on tracking bugs',
        TO_DATE('20-01-12','DD-MM-RR'),
        TO_DATE('10-03-12','DD-MM-RR'),
        'On-Hold',
        'Myra Sutcliff',
        0,
        2000,
        18
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        56,
        7,
        'End-user Training',
        TO_DATE('28-12-11','DD-MM-RR'),
        TO_DATE('22-02-12','DD-MM-RR'),
        'Open',
        'John Watson',
        0,
        2000,
        53
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        57,
        11,
        'Identify server requirements',
        TO_DATE('01-11-11','DD-MM-RR'),
        TO_DATE('02-11-11','DD-MM-RR'),
        'Closed',
        'John Watson',
        100,
        200,
        61
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        58,
        11,
        'Specify security authentication scheme(s)',
        TO_DATE('03-11-11','DD-MM-RR'),
        TO_DATE('05-11-11','DD-MM-RR'),
        'Closed',
        'John Watson',
        200,
        300,
        61
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        60,
        11,
        'Create pilot workspace',
        TO_DATE('10-11-11','DD-MM-RR'),
        TO_DATE('10-11-11','DD-MM-RR'),
        'Closed',
        'John Watson',
        100,
        100,
        61
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        61,
        11,
        'Configure Workspace provisioning',
        TO_DATE('10-11-11','DD-MM-RR'),
        TO_DATE('10-11-11','DD-MM-RR'),
        'Closed',
        'John Watson',
        200,
        100,
        NULL
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        62,
        11,
        'Run installation',
        TO_DATE('11-11-11','DD-MM-RR'),
        TO_DATE('11-11-11','DD-MM-RR'),
        'Closed',
        'James Cassidy',
        100,
        100,
        57
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        64,
        14,
        'Obtain equipment specifications',
        TO_DATE('03-01-12','DD-MM-RR'),
        TO_DATE('06-01-12','DD-MM-RR'),
        'Pending',
        'James Cassidy',
        0,
        500,
        67
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        65,
        3,
        'Purchase backup server',
        TO_DATE('12-01-12','DD-MM-RR'),
        TO_DATE('07-02-12','DD-MM-RR'),
        'Pending',
        'Mark Nile',
        0,
        3000,
        44
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        66,
        14,
        'Identify integration points',
        TO_DATE('08-01-12','DD-MM-RR'),
        TO_DATE('28-01-12','DD-MM-RR'),
        'Pending',
        'Mark Nile',
        0,
        2000,
        67
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        67,
        14,
        'Decommission machines',
        TO_DATE('08-01-12','DD-MM-RR'),
        TO_DATE('08-01-12','DD-MM-RR'),
        'Pending',
        'Scott Spencer',
        0,
        100,
        NULL
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        68,
        14,
        'Map data usage',
        TO_DATE('20-01-12','DD-MM-RR'),
        TO_DATE('03-03-12','DD-MM-RR'),
        'Pending',
        'Mark Nile',
        0,
        8000,
        67
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        69,
        14,
        'Purchase new machines',
        TO_DATE('24-02-12','DD-MM-RR'),
        TO_DATE('20-03-12','DD-MM-RR'),
        'Pending',
        'John Watson',
        0,
        2500,
        67
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        70,
        14,
        'Import data',
        TO_DATE('25-02-12','DD-MM-RR'),
        TO_DATE('23-03-12','DD-MM-RR'),
        'Pending',
        'John Watson',
        0,
        1000,
        67
    );

    INSERT INTO EBA_DEMO_CHART_TASKS (
        ID,
        PROJECT,
        TASK_NAME,
        START_DATE,
        END_DATE,
        STATUS,
        ASSIGNED_TO,
        COST,
        BUDGET,
        PARENT_TASK
    ) VALUES (
        71,
        14,
        'Convert processes',
        TO_DATE('02-02-12','DD-MM-RR'),
        TO_DATE('01-04-12','DD-MM-RR'),
        'Pending',
        'Pam King',
        0,
        3000,
        67
    );

    UPDATE EBA_DEMO_CHART_TASKS
        SET
            START_DATE = START_DATE + ( SYSDATE - TO_DATE('01012012','MMDDYYYY') ),
            END_DATE = END_DATE + ( SYSDATE - TO_DATE('01012012','MMDDYYYY') );
/* Charts Population Table Data */

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        51,
        'Wyoming',
        'WY',
        563626,
        4
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        9,
        'Georgia',
        'GA',
        9687653,
        3
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        17,
        'Tennessee',
        'TN',
        6346105,
        3
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        18,
        'Missouri',
        'MO',
        5988927,
        2
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        19,
        'Maryland',
        'MD',
        5773552,
        3
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        21,
        'Minnesota',
        'MN',
        5303925,
        2
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        36,
        'New Mexico',
        'NM',
        2059179,
        4
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        1,
        'California',
        'CA',
        37253956,
        4
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        2,
        'Texas',
        'TX',
        25145561,
        3
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        3,
        'New York',
        'NY',
        19378102,
        1
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        4,
        'Florida',
        'FL',
        18801310,
        3
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        5,
        'Illinois',
        'IL',
        12830310,
        2
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        6,
        'Pennsylvania',
        'PA',
        12702379,
        1
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        7,
        'Ohio',
        'OH',
        11536504,
        2
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        8,
        'Michigan',
        'MI',
        9883640,
        2
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        10,
        'North Carolina',
        'NC',
        9535483,
        3
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        11,
        'New Jersey',
        'NJ',
        8791894,
        1
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        12,
        'Virginia',
        'VA',
        8001024,
        3
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        13,
        'Washington',
        'WA',
        6724540,
        4
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        14,
        'Arizona',
        'AZ',
        6392017,
        4
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        15,
        'Massachusetts',
        'MA',
        6547629,
        1
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        16,
        'Indiana',
        'IN',
        6483802,
        2
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        20,
        'Wisconsin',
        'WI',
        5686986,
        2
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        22,
        'Colorado',
        'CO',
        5029196,
        4
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        23,
        'Alabama',
        'AL',
        4779736,
        3
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        24,
        'South Carolina',
        'SC',
        4625364,
        3
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        25,
        'Louisiana',
        'LA',
        4533372,
        3
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        26,
        'Kentucky',
        'KY',
        4339367,
        3
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        27,
        'Oregon',
        'OR',
        3831074,
        4
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        28,
        'Oklahoma',
        'OK',
        3751351,
        3
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        29,
        'Connecticut',
        'CT',
        3574097,
        1
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        30,
        'Iowa',
        'IA',
        3046355,
        2
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        31,
        'Mississippi',
        'MS',
        2967297,
        3
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        32,
        'Arkansas',
        'AR',
        2915918,
        3
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        33,
        'Kansas',
        'KS',
        2853118,
        2
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        34,
        'Utah',
        'UT',
        2763885,
        4
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        35,
        'Nevada',
        'NV',
        2700551,
        4
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        37,
        'West Virginia',
        'WV',
        1852994,
        3
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        38,
        'Nebraska',
        'NE',
        1826341,
        2
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        39,
        'Idaho',
        'ID',
        1567582,
        4
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        40,
        'Maine',
        'ME',
        1328361,
        1
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        41,
        'New Hampshire',
        'NH',
        1316470,
        1
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        42,
        'Hawaii',
        'HI',
        1360301,
        4
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        43,
        'Rhode Island',
        'RI',
        1052567,
        1
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        44,
        'Montana',
        'MT',
        989415,
        4
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        45,
        'Delaware',
        'DE',
        897934,
        3
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        46,
        'South Dakota',
        'SD',
        814180,
        2
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        47,
        'Alaska',
        'AK',
        710231,
        4
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        48,
        'North Dakota',
        'ND',
        672591,
        2
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        49,
        'Vermont',
        'VT',
        625741,
        1
    );

    INSERT INTO EBA_DEMO_CHART_POPULATION (
        ID,
        STATE_NAME,
        STATE_CODE,
        POPULATION,
        REGION
    ) VALUES (
        50,
        'District of Columbia',
        'DC',
        601723,
        3
    );
/* Charts Dept Table */

    INSERT INTO EBA_DEMO_CHART_DEPT (
        DEPTNO,
        DNAME,
        LOC
    ) VALUES (
        10,
        'ACCOUNTING',
        'NEW YORK'
    );

    INSERT INTO EBA_DEMO_CHART_DEPT (
        DEPTNO,
        DNAME,
        LOC
    ) VALUES (
        20,
        'RESEARCH',
        'DALLAS'
    );

    INSERT INTO EBA_DEMO_CHART_DEPT (
        DEPTNO,
        DNAME,
        LOC
    ) VALUES (
        30,
        'SALES',
        'CHICAGO'
    );

    INSERT INTO EBA_DEMO_CHART_DEPT (
        DEPTNO,
        DNAME,
        LOC
    ) VALUES (
        40,
        'OPERATIONS',
        'BOSTON'
    );
/* Charts Emp Table */

    INSERT INTO EBA_DEMO_CHART_EMP (
        EMPNO,
        ENAME,
        JOB,
        MGR,
        HIREDATE,
        SAL,
        COMM,
        DEPTNO
    ) VALUES (
        7839,
        'KING',
        'PRESIDENT',
        NULL,
        TO_DATE('17-11-81','DD-MM-RR'),
        5000,
        NULL,
        10
    );

    INSERT INTO EBA_DEMO_CHART_EMP (
        EMPNO,
        ENAME,
        JOB,
        MGR,
        HIREDATE,
        SAL,
        COMM,
        DEPTNO
    ) VALUES (
        7698,
        'BLAKE',
        'MANAGER',
        7839,
        TO_DATE('01-05-81','DD-MM-RR'),
        2850,
        NULL,
        30
    );

    INSERT INTO EBA_DEMO_CHART_EMP (
        EMPNO,
        ENAME,
        JOB,
        MGR,
        HIREDATE,
        SAL,
        COMM,
        DEPTNO
    ) VALUES (
        7782,
        'CLARK',
        'MANAGER',
        7839,
        TO_DATE('09-06-81','DD-MM-RR'),
        2450,
        NULL,
        10
    );

    INSERT INTO EBA_DEMO_CHART_EMP (
        EMPNO,
        ENAME,
        JOB,
        MGR,
        HIREDATE,
        SAL,
        COMM,
        DEPTNO
    ) VALUES (
        7566,
        'JONES',
        'MANAGER',
        7839,
        TO_DATE('02-04-81','DD-MM-RR'),
        2975,
        NULL,
        20
    );

    INSERT INTO EBA_DEMO_CHART_EMP (
        EMPNO,
        ENAME,
        JOB,
        MGR,
        HIREDATE,
        SAL,
        COMM,
        DEPTNO
    ) VALUES (
        7788,
        'SCOTT',
        'ANALYST',
        7566,
        TO_DATE('09-12-82','DD-MM-RR'),
        3000,
        NULL,
        20
    );

    INSERT INTO EBA_DEMO_CHART_EMP (
        EMPNO,
        ENAME,
        JOB,
        MGR,
        HIREDATE,
        SAL,
        COMM,
        DEPTNO
    ) VALUES (
        7902,
        'FORD',
        'ANALYST',
        7566,
        TO_DATE('03-12-81','DD-MM-RR'),
        3000,
        NULL,
        20
    );

    INSERT INTO EBA_DEMO_CHART_EMP (
        EMPNO,
        ENAME,
        JOB,
        MGR,
        HIREDATE,
        SAL,
        COMM,
        DEPTNO
    ) VALUES (
        7369,
        'SMITH',
        'CLERK',
        7902,
        TO_DATE('17-12-80','DD-MM-RR'),
        800,
        NULL,
        20
    );

    INSERT INTO EBA_DEMO_CHART_EMP (
        EMPNO,
        ENAME,
        JOB,
        MGR,
        HIREDATE,
        SAL,
        COMM,
        DEPTNO
    ) VALUES (
        7499,
        'ALLEN',
        'SALESMAN',
        7698,
        TO_DATE('20-02-81','DD-MM-RR'),
        1600,
        300,
        30
    );

    INSERT INTO EBA_DEMO_CHART_EMP (
        EMPNO,
        ENAME,
        JOB,
        MGR,
        HIREDATE,
        SAL,
        COMM,
        DEPTNO
    ) VALUES (
        7521,
        'WARD',
        'SALESMAN',
        7698,
        TO_DATE('22-02-81','DD-MM-RR'),
        1250,
        500,
        30
    );

    INSERT INTO EBA_DEMO_CHART_EMP (
        EMPNO,
        ENAME,
        JOB,
        MGR,
        HIREDATE,
        SAL,
        COMM,
        DEPTNO
    ) VALUES (
        7654,
        'MARTIN',
        'SALESMAN',
        7698,
        TO_DATE('28-09-81','DD-MM-RR'),
        1250,
        1400,
        30
    );

    INSERT INTO EBA_DEMO_CHART_EMP (
        EMPNO,
        ENAME,
        JOB,
        MGR,
        HIREDATE,
        SAL,
        COMM,
        DEPTNO
    ) VALUES (
        7844,
        'TURNER',
        'SALESMAN',
        7698,
        TO_DATE('08-09-81','DD-MM-RR'),
        1500,
        0,
        30
    );

    INSERT INTO EBA_DEMO_CHART_EMP (
        EMPNO,
        ENAME,
        JOB,
        MGR,
        HIREDATE,
        SAL,
        COMM,
        DEPTNO
    ) VALUES (
        7876,
        'ADAMS',
        'CLERK',
        7788,
        TO_DATE('12-01-83','DD-MM-RR'),
        1100,
        NULL,
        20
    );

    INSERT INTO EBA_DEMO_CHART_EMP (
        EMPNO,
        ENAME,
        JOB,
        MGR,
        HIREDATE,
        SAL,
        COMM,
        DEPTNO
    ) VALUES (
        7900,
        'JAMES',
        'CLERK',
        7698,
        TO_DATE('03-12-81','DD-MM-RR'),
        950,
        NULL,
        30
    );

    INSERT INTO EBA_DEMO_CHART_EMP (
        EMPNO,
        ENAME,
        JOB,
        MGR,
        HIREDATE,
        SAL,
        COMM,
        DEPTNO
    ) VALUES (
        7934,
        'MILLER',
        'CLERK',
        7782,
        TO_DATE('23-01-82','DD-MM-RR'),
        1300,
        NULL,
        10
    );
/* Charts BBall Table */

    INSERT INTO EBA_DEMO_CHART_BBALL (
        ID,
        CITY,
        TEAM,
        CONFERENCE,
        WINS
    ) VALUES (
        1,
        'Boston',
        'Celtics',
        'East',
        17
    );

    INSERT INTO EBA_DEMO_CHART_BBALL (
        ID,
        CITY,
        TEAM,
        CONFERENCE,
        WINS
    ) VALUES (
        2,
        'Los Angeles',
        'Lakers',
        'West',
        16
    );

    INSERT INTO EBA_DEMO_CHART_BBALL (
        ID,
        CITY,
        TEAM,
        CONFERENCE,
        WINS
    ) VALUES (
        3,
        'Chicago',
        'Bulls',
        'East',
        6
    );

    INSERT INTO EBA_DEMO_CHART_BBALL (
        ID,
        CITY,
        TEAM,
        CONFERENCE,
        WINS
    ) VALUES (
        4,
        'San Antonio',
        'Spurs',
        'West',
        5
    );

    INSERT INTO EBA_DEMO_CHART_BBALL (
        ID,
        CITY,
        TEAM,
        CONFERENCE,
        WINS
    ) VALUES (
        5,
        'Golden Gate',
        'Warriors',
        'West',
        4
    );

    INSERT INTO EBA_DEMO_CHART_BBALL (
        ID,
        CITY,
        TEAM,
        CONFERENCE,
        WINS
    ) VALUES (
        6,
        'Philadelphia',
        '76ers',
        'East',
        3
    );

    INSERT INTO EBA_DEMO_CHART_BBALL (
        ID,
        CITY,
        TEAM,
        CONFERENCE,
        WINS
    ) VALUES (
        7,
        'Detroit',
        'Pistons',
        'East',
        3
    );

    INSERT INTO EBA_DEMO_CHART_BBALL (
        ID,
        CITY,
        TEAM,
        CONFERENCE,
        WINS
    ) VALUES (
        8,
        'Miami',
        'Heat',
        'East',
        3
    );

    INSERT INTO EBA_DEMO_CHART_BBALL (
        ID,
        CITY,
        TEAM,
        CONFERENCE,
        WINS
    ) VALUES (
        9,
        'New York',
        'Knicks',
        'East',
        2
    );

    INSERT INTO EBA_DEMO_CHART_BBALL (
        ID,
        CITY,
        TEAM,
        CONFERENCE,
        WINS
    ) VALUES (
        10,
        'Houston',
        'Rockets',
        'West',
        2
    );
/* Charts Products Tables */

    INSERT INTO EBA_DEMO_CHART_PRODUCTS (
        PRODUCT_ID,
        PRODUCT_NAME,
        PRODUCT_DESCRIPTION,
        LIST_PRICE
    ) VALUES (
        1,
        'Apples',
        'Red pink lady apples',
        1.20
    );

    INSERT INTO EBA_DEMO_CHART_PRODUCTS (
        PRODUCT_ID,
        PRODUCT_NAME,
        PRODUCT_DESCRIPTION,
        LIST_PRICE
    ) VALUES (
        2,
        'Bananas',
        'Bunches of yellow bananas',
        3.80
    );

    INSERT INTO EBA_DEMO_CHART_PRODUCTS (
        PRODUCT_ID,
        PRODUCT_NAME,
        PRODUCT_DESCRIPTION,
        LIST_PRICE
    ) VALUES (
        3,
        'Cantaloupe',
        'Coral coloured melon',
        2.95
    );

    INSERT INTO EBA_DEMO_CHART_PRODUCTS (
        PRODUCT_ID,
        PRODUCT_NAME,
        PRODUCT_DESCRIPTION,
        LIST_PRICE
    ) VALUES (
        4,
        'Dates',
        'Dried dates',
        3.30
    );

    INSERT INTO EBA_DEMO_CHART_PRODUCTS (
        PRODUCT_ID,
        PRODUCT_NAME,
        PRODUCT_DESCRIPTION,
        LIST_PRICE
    ) VALUES (
        5,
        'Grapes',
        'Punnet of Red Seedless Grapes',
        2.05
    );
/* Charts Orders Table */

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        1,
        1,
        42,
        'Store A',
        TO_DATE('08-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        2,
        2,
        55,
        'Store A',
        TO_DATE('09-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        3,
        3,
        36,
        'Store A',
        TO_DATE('11-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        4,
        4,
        22,
        'Store A',
        TO_DATE('12-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        5,
        5,
        42,
        'Store A',
        TO_DATE('14-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        6,
        1,
        32,
        'Acme Store',
        TO_DATE('03-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        7,
        2,
        39,
        'Acme Store',
        TO_DATE('04-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        8,
        3,
        36,
        'Acme Store',
        TO_DATE('07-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        9,
        4,
        27,
        'Acme Store',
        TO_DATE('13-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        10,
        5,
        50,
        'Acme Store',
        TO_DATE('14-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        11,
        1,
        34,
        'Shop C',
        TO_DATE('08-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        12,
        2,
        30,
        'Shop C',
        TO_DATE('09-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        13,
        3,
        50,
        'Shop C',
        TO_DATE('11-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        14,
        4,
        46,
        'Shop C',
        TO_DATE('12-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        15,
        5,
        36,
        'Shop C',
        TO_DATE('14-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        16,
        1,
        74,
        'Deli',
        TO_DATE('02-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        17,
        2,
        42,
        'Deli',
        TO_DATE('04-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        18,
        3,
        70,
        'Deli',
        TO_DATE('06-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        19,
        4,
        46,
        'Deli',
        TO_DATE('08-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER,
        SALES_DATE
    ) VALUES (
        20,
        5,
        22,
        'Deli',
        TO_DATE('10-04-16','DD-MM-RR')
    );

    INSERT INTO EBA_DEMO_CHART_ORDERS (
        ORDER_ID,
        PRODUCT_ID,
        QUANTITY,
        CUSTOMER
    ) VALUES (
        21,
        5,
        30,
        'Grocery Store'
    );
/* Charts Stats Table */

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'AU',
        'Australia',
        0,
        0,
        0
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'BE',
        'Belgium',
        3.5,
        3.7,
        7.8
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'CA',
        'Canada',
        2.3,
        2,
        4.7
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'CZ',
        'Czech Republic',
        1.8,
        6,
        8.3
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'DK',
        'Denmark',
        0,
        0,
        0
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'FI',
        'Finland',
        1.8,
        6.8,
        9
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'DE',
        'Germany',
        2.8,
        3.2,
        6.9
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'GR',
        'Greece',
        3.4,
        4.3,
        9.2
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'HU',
        'Hungary',
        1.4,
        6.4,
        8.3
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'IT',
        'Italy',
        2.2,
        6.8,
        9
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'JA',
        'Japan',
        3.2,
        3.1,
        6.3
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'KO',
        'Korea',
        1.2,
        0.9,
        2.1
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'LU',
        'Luxembourg',
        2.8,
        2.4,
        5.9
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'MX',
        'Mexico',
        0,
        0,
        0
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'NZ',
        'New Zealand',
        0,
        0,
        0
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'PO',
        'Poland',
        3,
        2.6,
        6.8
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'SK',
        'Slovakia',
        0.9,
        2.5,
        4.3
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'ES',
        'Spain',
        1.4,
        6.8,
        9.2
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'SE',
        'Sweden',
        2.5,
        3.6,
        6.2
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'CH',
        'Switzerland',
        2.7,
        2.7,
        5.9
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'TR',
        'Turkey',
        1.1,
        1.3,
        2.4
    );

    INSERT INTO EBA_DEMO_CHART_STATS (
        NAME,
        COUNTRY,
        EMPLOYEE,
        EMPLOYER,
        TOTAL
    ) VALUES (
        'US',
        'United States',
        1.8,
        3,
        5.2
    );
/* Charts Stocks Table Data */

    L_OPEN := 200;
    L_CLOSE := DBMS_RANDOM.VALUE * 5 + 200;
    INSERT INTO EBA_DEMO_CHART_STOCKS (
        ID,
        STOCK_CODE,
        STOCK_NAME,
        PRICING_DATE,
        OPENING_VAL,
        HIGH,
        LOW,
        CLOSING_VAL,
        VOLUME
    ) VALUES (
        1,
        'METR',
        'Metro Trading',
        LOCALTIMESTAMP - 500,
        200,
        202,
        199,
        L_CLOSE,
        1000000
    );

    FOR I IN 1..500 LOOP
        L_OPEN := L_CLOSE;
        L_CLOSE := L_OPEN + DBMS_RANDOM.VALUE * 5 * POWER(-1,ROUND(DBMS_RANDOM.VALUE) );

        L_HIGH := GREATEST(L_OPEN,L_CLOSE) + DBMS_RANDOM.VALUE * 2;
        L_LOW := LEAST(L_OPEN,L_CLOSE) - DBMS_RANDOM.VALUE * 2;
        L_VOLUME := 1000000 + DBMS_RANDOM.VALUE * 10000000;
        INSERT INTO EBA_DEMO_CHART_STOCKS (
            ID,
            STOCK_CODE,
            STOCK_NAME,
            PRICING_DATE,
            OPENING_VAL,
            HIGH,
            LOW,
            CLOSING_VAL,
            VOLUME
        ) VALUES (
            I + 1,
            'METR',
            'Metro Trading',
            LOCALTIMESTAMP - 500 + I,
            L_OPEN,
            L_HIGH,
            L_LOW,
            L_CLOSE,
            L_VOLUME
        );

    END LOOP;

END;
/

