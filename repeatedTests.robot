*** Settings ***
Documentation     This test suite shows how to keep robot tests simple and avoid redundant code with repeated cases.
...  Suppose we are given a keyword that proves whether the given server is reachable.
...  We have three similar test cases (repeated steps) one test case with reapeted steps:
...  1) Either the servers (S1 and S2) or (S3 and S4 and (S7 or S8 or S9)) or S5 or S6 need to be reachable.
...  2) Either the servers (S1 and S3) or (S2 and S4 and (S7 or S8 or S9)) or S5 or S6 need to be reachable.
...  3) Either the servers (S1 and S4) or (S3 and S2 and (S7 or S8 or S5)) or S9 or S6 need to be reachable.
...  Test case 1 approach:
...      The order is prioritised means firstly checked if (S1 and S2) is reachable.
...      If not then the second goup can be checked (S3 and S4 and (S7 or S8 or S9)) 
...      If not then S5 If not then S6.
...  *Divide and conquer* Methode which we know also from stillReadable.robot file.
...  Could also be used. So we can let robot test remain readable as much as possible.
...  But there is also a better suitable way, which robot provides for such cases.
...  the [Template].
...  Abstract the logic and the steps to a single keyword and feed to it different data.
...  So the tests can be written as simple as possible in one case.

*** Variables ***
${S1}  fe80::aede::1121
${S2}  fe80::aede::1122
${S3}  fe80::aede::1123
${S4}  fe80::aede::1124
${S5}  fe80::aede::1125
${S6}  fe80::aede::1126
${S7}  fe80::aede::1127
${S8}  fe80::aede::1128
${S9}  fe80::aede::1129

*** Keywords ***
Is Reachable
    [Arguments]  ${ServerIP}
    # provided operation here
    No Operation

All Reachable Ands
    [Arguments]  @{SERVERS}
    FOR    ${server}    IN    @{SERVERS}
        Is Reachable  ${server}
    END

One Reachable Ors
    [Arguments]  @{SERVERS}
    FOR    ${server}    IN    @{SERVERS}
        ${status}  Run Keyword And Return Status    Is Reachable  ${server}
        Return From Keyword If    ${status}==True
    END
    Fail  ${SERVERS} are not reachable

(${SERVER1} and ${SERVER2}) or (${SERVER3} and ${SERVER4} and (${SERVER5} or ${SERVER6} or ${SERVER7})) or ${SERVER8} or ${SERVER9} Reachable
    ${status}  Run Keyword And Return Status    All Reachable Ands  ${SERVER1}  ${SERVER2}
    Return From Keyword If   ${status}==True
    ${status1}  Run Keyword And Return Status   All Reachable Ands  ${SERVER3}  ${SERVER4}
    ${status2}  Run Keyword And Return Status   One Reachable Ors  ${SERVER5}  ${SERVER6}  ${SERVER7}
    Return From Keyword If   ${status1}==True and ${status2}==True
    ${status}  Run Keyword And Return Status    Is Reachable  ${SERVER8}
    Return From Keyword If   ${status}==True
    ${status}  Run Keyword And Return Status    Is Reachable  ${SERVER9}
    Return From Keyword If   ${status}==True
    Fail  Servers Not Reachable

*** Test Cases ***
Not Readable But Good Abstracted Test Cases 1 2 3
    [Documentation]
    [Template]    (${SERVER1} and ${SERVER2}) or (${SERVER3} and ${SERVER4} and (${SERVER5} or ${SERVER6} or ${SERVER7})) or ${SERVER8} or ${SERVER9} Reachable
    ${S1}  ${S2}  ${S3}  ${S4}  ${S7}  ${S8}  ${S9}  ${S5}  ${S6}
    ${S1}  ${S3}  ${S2}  ${S4}  ${S7}  ${S8}  ${S9}  ${S5}  ${S6}
    ${S1}  ${S4}  ${S3}  ${S2}  ${S7}  ${S8}  ${S5}  ${S9}  ${S6}

# Currently there is no better way to remain better readable and
# still have all the tests in one place without redundancy

# A test case without using template keywords may look like as the following.
# Not sugested

Not Templated Readable Test Case 1
    (S1 and S2) or (S3 and S4 and (S7 or S8 or S9)) or S5 or S6 Reachable  # should be individualy implemented (not yet implemented)

Not Templated Readable Test Case 2
    (S1 and S3) or (S2 and S4 and (S7 or S8 or S9)) or S5 or S6 Reachable  # should be individualy implemented (not yet implemented)

Not Templated Readable Test Case 3
    (S1 and S4) or (S3 and S2 and (S7 or S8 or S5)) or S9 or S6 Reachable  # should be individualy implemented (not yet implemented)

# Template (first approach) is the way to go
# Pros: No redundant code, Easier and faster to write, No transparency difference.
# Contras: Less readable.

# There are also other ways to implement it but no single one of those will keep the test as simple as the first case does.
# So the first variant for sure is better way to go.
