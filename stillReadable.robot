*** Settings ***
Documentation     This test suite shows how to keep robot tests readable.
...  Suppose we are given a keyword that proves whether the given server is reachable.
...  The test case says:
...  Either the servers (S1 and S2) or (S3 and S4 and (S7 or S8 or S9)) or S5 or S6 need to be reachable.
...  The order is prioritised means firstly checked if (S1 and S2) is reachable.
...  If not then the second goup can be checked (S3 and S4 and (S7 or S8 or S9)) 
...  If not then S5 If not then S6.
...  
...  What if we make several keywords to check each group individualy .
...  So we can let robot test remain readable as much as possible. 
...  *Divide and conquer* Methode
...  Abstract the logic to simple chunks of keywords so we keep the test readable.
...  This way of abstraction is the only way to keep tests readable in robot.

...  Otherwise we are integrating the Behavior Tree in Robot Framework as a Library
...  It can also serve as an alternative solution.

Library    BehaviorTreeLibrary

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

S1 And S2 Reachable
    Is Reachable  $S1
    IS Reachable  $S2

S7 Or S8 Or S9 Reachable
    ${status}  Run Keyword And Return Status    Is Reachable  $S7
    Return From Keyword If    ${status}==True
    ${status}  Run Keyword And Return Status    Is Reachable  $S8
    Return From Keyword If    ${status}==True
    ${status}  Run Keyword And Return Status    Is Reachable  $S9
    Return From Keyword If    ${status}==True
    Fail  S7 and S8 and S9 are not reachable

S3 And S4 And (S7 Or S8 Or S9) Reachable
    Is Reachable  $S3
    Is Reachable  $S4
    S7 Or S8 Or S9 Reachable

(S1 and S2) or (S3 and S4 and (S7 or S8 or S9)) or S5 or S6 Reachable
    ${status}  Run Keyword And Return Status    S1 And S2 Reachable
    IF  ${status}==True
        Pass Execution    S1 and S2 are reachable
    END
    ${status}  Run Keyword And Return Status    S3 And S4 And (S7 Or S8 Or S9) Reachable
    IF  ${status}==True
        Pass Execution    S3 and S4 and (S7 or S8 or S9) are reachable
    END
    ${status}  Run Keyword And Return Status    Is Reachable  $S8
    IF  ${status}==True
        Pass Execution    S8 is reachable
    END
    ${status}  Run Keyword And Return Status    Is Reachable  $S9
    IF  ${status}==True
        Pass Execution    S9 is reachable
    END
    Fail  Servers Not Reachable

*** Test Cases ***
Still Readable Test Case
    [Documentation]
    (S1 and S2) or (S3 and S4 and (S7 or S8 or S9)) or S5 or S6 Reachable

# currently there is no possible way to remain readable and still have all the neccessary action keywords
#  within the test case without abstracting them (transparency).
# A test case without abstracted keywords may look like as the following./

Not Readable Test Case
    ${status1}  Run Keyword And Return Status    Is Reachable  $S1
    ${status2}  Run Keyword And Return Status    Is Reachable  $S2
    IF  ${status1}==True and ${status2}==True
        Pass Execution    S1 and S2 are reachable
    END
    ${status3}  Run Keyword And Return Status  Is Reachable  $S3
    ${status4}  Run Keyword And Return Status  Is Reachable  $S4
    ${status7}  Run Keyword And Return Status  Is Reachable  $S7
    IF  ${status3}==True and ${status4}==True and ${status7}==True
        Pass Execution    S3 and S4 and (S7 or S8 or S9) are reachable
    END
    ${status8}  Run Keyword And Return Status  Is Reachable  $S8
    IF  ${status3}==True and ${status4}==True and ${status8}==True
        Pass Execution    S3 and S4 and (S7 or S8 or S9) are reachable
    END
    ${status9}  Run Keyword And Return Status    Is Reachable  $S9
    IF  ${status3}==True and ${status4}==True and ${status9}==True
        Pass Execution    S3 and S4 and (S7 or S8 or S9) are reachable
    END
    ${status}  Run Keyword And Return Status    Is Reachable  $S8
    IF  ${status}==True
        Pass Execution    S8 is reachable
    END
    ${status}  Run Keyword And Return Status    Is Reachable  $S9
    IF  ${status}==True
        Pass Execution    S9 is reachable
    END
    Fail  Servers Not Reachable

# There are of course many other ways to write
# but no single one of those will keep the test readable as much as the first case does.
# So the first variant for sure is better way to go.

# Behavior Tree Could also help see the following equivalent test case written with the help of
# Behavior Tree Library
Behavior Tree Test Case
    One Should Pass
    ...  -  All Should Pass
    ...  -  -  S1 Is Reachable
    ...  -  -  S2 Is Reachable
    ...  -  All Should Pass
    ...  -  -  S3 Is Reachable
    ...  -  -  S4 Is Reachable
    ...  -  -  One Should Pass
    ...  -  -  - S7 Is Reachable
    ...  -  -  - S8 Is Reachable
    ...  -  -  - S9 Is Reachable
    ...  -  S5 Is Reachable
    ...  -  S6 Is Reachable