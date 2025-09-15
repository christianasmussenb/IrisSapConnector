/// Estilos base para la aplicación PETS
Class Demo.PETS.CSS.Base Extends %CSP.Page [ Not ProcedureBlock ]
{

/// Generar CSS base del sistema
ClassMethod GenerateCSS() As %String
{
    Set css = ""
    Set css = css _ "/* ==================================" _ $c(13,10)
    Set css = css _ "   ESTILOS BASE - SISTEMA PETS" _ $c(13,10)
    Set css = css _ "   ================================== */" _ $c(13,10)
    Set css = css _ $c(13,10)
    
    Set css = css _ "body {" _ $c(13,10)
    Set css = css _ "    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;" _ $c(13,10)
    Set css = css _ "    margin: 0;" _ $c(13,10)
    Set css = css _ "    padding: 20px;" _ $c(13,10)
    Set css = css _ "    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);" _ $c(13,10)
    Set css = css _ "    min-height: 100vh;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    Set css = css _ $c(13,10)
    
    Quit css
}

}
