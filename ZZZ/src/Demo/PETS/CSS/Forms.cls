/// Estilos para formularios de la aplicación PETS
Class Demo.PETS.CSS.Forms Extends %CSP.Page [ Not ProcedureBlock ]
{

/// Generar CSS para formularios
ClassMethod GenerateCSS() As %String
{
    Set css = ""
    Set css = css _ "/* ==================================" _ $c(13,10)
    Set css = css _ "   ESTILOS FORMULARIOS - SISTEMA PETS" _ $c(13,10)
    Set css = css _ "   ================================== */" _ $c(13,10)
    Set css = css _ $c(13,10)
    
    Set css = css _ ".form-section {" _ $c(13,10)
    Set css = css _ "    padding: 30px;" _ $c(13,10)
    Set css = css _ "    border-bottom: 1px solid #eee;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ "input, select, textarea, button {" _ $c(13,10)
    Set css = css _ "    padding: 10px;" _ $c(13,10)
    Set css = css _ "    margin: 5px;" _ $c(13,10)
    Set css = css _ "    border: 1px solid #ddd;" _ $c(13,10)
    Set css = css _ "    border-radius: 4px;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ "input, select, textarea {" _ $c(13,10)
    Set css = css _ "    width: 300px;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ "button {" _ $c(13,10)
    Set css = css _ "    background: #3498db;" _ $c(13,10)
    Set css = css _ "    color: white;" _ $c(13,10)
    Set css = css _ "    cursor: pointer;" _ $c(13,10)
    Set css = css _ "    border: none;" _ $c(13,10)
    Set css = css _ "    padding: 10px 20px;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ "button:hover {" _ $c(13,10)
    Set css = css _ "    background: #2980b9;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ ".form-group {" _ $c(13,10)
    Set css = css _ "    margin: 15px 0;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ "label {" _ $c(13,10)
    Set css = css _ "    display: block;" _ $c(13,10)
    Set css = css _ "    margin-bottom: 5px;" _ $c(13,10)
    Set css = css _ "    font-weight: bold;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Quit css
}

}
