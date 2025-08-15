/// UtilityService - Handles common utility functions and ID generation
Class Demo.PETS.Services.UtilityService Extends Demo.PETS.Services.Base
{

/// Generate unique UserID for pets
/// Format: PET-YYYY-NNNN (e.g: PET-2024-0001)
ClassMethod GenerateUniqueUserID() As %String
{
    Set year = $ZDate($H, 3)
    Set year = $Extract(year, 1, 4)
    
    // Find the last UserID of the current year
    Set sql = "SELECT MAX(UserID) FROM Demo_PETS.Pets WHERE UserID LIKE 'PET-"_year_"-%'"
    Set statement = ##class(%SQL.Statement).%New()
    Set sc = statement.%Prepare(sql)
    Set result = statement.%Execute()
    
    Set maxUserID = ""
    If result.%Next() {
        Set maxUserID = result.%GetData(1)
    }
    
    // Extract sequential number and increment
    Set nextNumber = 1
    If (maxUserID '= "") && ($Length(maxUserID, "-") = 3) {
        Set numberPart = $Piece(maxUserID, "-", 3)
        If $IsValidNum(numberPart) {
            Set nextNumber = numberPart + 1
        }
    }
    
    // Format with leading zeros (4 digits)
    Set numberStr = $Translate($Justify(nextNumber, 4), " ", "0")
    
    Return "PET-"_year_"-"_numberStr
}

/// Generate unique RUT for testing purposes
ClassMethod GenerateUniqueRUT() As %String
{
    Set timestamp = $H
    Set random = $Random(999999)
    Set baseNumber = $Extract($Piece(timestamp, ",", 2), 1, 6) _ random
    Set baseNumber = $Extract(baseNumber _ "00000000", 1, 8)
    
    // Calculate verification digit (simplified)
    Set checkDigit = $Random(9)
    
    Return baseNumber _ "-" _ checkDigit
}

/// Validate RUT format (Chilean format)
ClassMethod ValidateRUTFormat(rut As %String) As %Boolean
{
    If rut = "" Return 0
    
    // Basic format check: XXXXXXXX-X
    If '$Match(rut, "^[0-9]{7,8}-[0-9kK]$") {
        Return 0
    }
    
    Return 1
}

/// Format phone number consistently
ClassMethod FormatPhoneNumber(phone As %String) As %String
{
    If phone = "" Return ""
    
    // Remove non-numeric characters except + and -
    Set cleanPhone = $TR(phone, " ().", "")
    
    // Add basic formatting if needed
    If $Length(cleanPhone) = 9 && ($Extract(cleanPhone, 1) '= "+") {
        Set cleanPhone = "+56" _ cleanPhone
    }
    
    Return cleanPhone
}

/// Validate email format
ClassMethod ValidateEmailFormat(email As %String) As %Boolean
{
    If email = "" Return 1  // Email is optional
    
    // Basic email validation
    If '$Match(email, "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$") {
        Return 0
    }
    
    Return 1
}

/// Clean and format text input
ClassMethod CleanTextInput(text As %String) As %String
{
    If text = "" Return ""
    
    // Trim whitespace
    Set cleanText = $ZStrip(text, "<>W")
    
    // Capitalize first letter of each word
    Set cleanText = $ZConvert(cleanText, "W")
    
    Return cleanText
}

}
