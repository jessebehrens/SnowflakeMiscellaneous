# SnowflakeMiscellaneous
This repository is to provide small code snippets for customers to demonstrate specific Snowflake features.

<ul>
<li>
<b>RowAccessPolicies.sql</b> - This code is designed to create sample roles, data, and tables for common demonstration purposes. Row base access policies are applied to these common datasets to demonstrate how specific roles can only see certain rows within the <b>same</b> table.<br>


<ol><li>Lines 1 through 62 are just setting up my environment. I wanted us to have common roles, data, and environments. The first 62 lines are just setting this up so we have a common ground to work through. They are not needed for production environments </li>





<li>Lines 63 through 84 are actually creating the row base access policies</li>
<li>Lines 63 through 73 create a mapping table that maps what roles can access what rows</li>
<li>Lines 76 through 81 create the actual policy object</li>
<li>Line 84 applies the policy to our table.  This is a reusable object and can be used on multiple objects if we choose</li>
<li>Lines 86 through 99 just simulate the different roles and show how the results differ based on the roles a user has</li>
</ol>
</li>
</ul>
