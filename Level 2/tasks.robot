*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium
Library             RPA.PDF
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.Excel.Files
Library             RPA.FileSystem
Library             RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    ${csvFile}=    Download CSV file
    Open the robot order website
    FOR    ${order}    IN    @{csvFile}
        Close Annoying Modal
        Fill out form from csv file    ${order}
        Wait Until Keyword Succeeds    1x    5s    Preview
        Wait Until Keyword Succeeds    30x    5s    Order Robot
        Store the receipt as a PDF file    ${order}[Order number]
        Take screenshot    ${order}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${OUTPUT_DIR}${/}${order}[Order number]
        Delete Screenshot    ${OUTPUT_DIR}${/}${order}[Order number]
        Close Receipt
    END
    Archive pdfs


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download CSV file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}
    ${orders}=    Read table from CSV    orders.csv    header=${True}
    RETURN    ${orders}

Close Annoying Modal
    Wait And Click Button    xpath://html/body/div/div/div[2]/div/div/div/div/div/button[1]

Fill out form from csv file
    [Arguments]    ${order}
    Select From List By Value    id:head    ${order}[Head]
    FOR    ${element}    IN    @{order}
        Select Radio Button    body    ${order}[Body]
    END
    Input Text    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${order}[Legs]
    Input Text    id:address    ${order}[Address]

Preview
    Click Button    id:preview
    Wait Until Element Is Visible    id:robot-preview-image

Order Robot
    Click Button    id:order
    Wait Until Element Is Visible    id:receipt

Take screenshot
    [Arguments]    ${OrderNum}
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}${OrderNum}_screenshot.png

Store the receipt as a PDF file
    [Arguments]    ${orderNum}
    ${html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${html}    ${OUTPUT_DIR}${/}${orderNum}_pdf.pdf

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${outputdir}
    @{list}=    Create List    ${outputdir}_screenshot.png
    Open Pdf    ${outputdir}_pdf.pdf
    Add Watermark Image To Pdf    ${outputdir}_screenshot.png    ${outputdir}_pdf.pdf
    Close Pdf    ${outputdir}_pdf.pdf

Delete Screenshot
    [Arguments]    ${outputdir}
    Remove File    ${outputdir}_screenshot.png

Close Receipt
    Click Button    id:order-another

Archive pdfs
    Archive Folder With Zip    ${OUTPUT_DIR}    receipts.zip    include=*.pdf
