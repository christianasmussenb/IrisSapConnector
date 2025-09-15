/// Estilos para tablas y consultas de la aplicación PETS
Class Demo.PETS.CSS.Tables Extends %CSP.Page [ Not ProcedureBlock ]
{

/// Generar CSS para tablas
ClassMethod GenerateCSS() As %String
{
    Set css = ""
    Set css = css _ "/* ==================================" _ $c(13,10)
    Set css = css _ "   ESTILOS TABLAS - SISTEMA PETS" _ $c(13,10)
    Set css = css _ "   ================================== */" _ $c(13,10)
    Set css = css _ $c(13,10)
    
    Set css = css _ "table {" _ $c(13,10)
    Set css = css _ "    width: 100%;" _ $c(13,10)
    Set css = css _ "    border-collapse: collapse;" _ $c(13,10)
    Set css = css _ "    margin: 20px 0;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ "th, td {" _ $c(13,10)
    Set css = css _ "    padding: 12px;" _ $c(13,10)
    Set css = css _ "    text-align: left;" _ $c(13,10)
    Set css = css _ "    border-bottom: 1px solid #ddd;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ "th {" _ $c(13,10)
    Set css = css _ "    background-color: #3498db;" _ $c(13,10)
    Set css = css _ "    color: white;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ "tr:hover {" _ $c(13,10)
    Set css = css _ "    background-color: #f5f5f5;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ ".btn-back {" _ $c(13,10)
    Set css = css _ "    background: #95a5a6;" _ $c(13,10)
    Set css = css _ "    color: white;" _ $c(13,10)
    Set css = css _ "    text-decoration: none;" _ $c(13,10)
    Set css = css _ "    padding: 10px 20px;" _ $c(13,10)
    Set css = css _ "    border-radius: 4px;" _ $c(13,10)
    Set css = css _ "    display: inline-block;" _ $c(13,10)
    Set css = css _ "    margin: 20px 0;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ ".status-activo, .disponible, .activo {" _ $c(13,10)
    Set css = css _ "    color: #27ae60;" _ $c(13,10)
    Set css = css _ "    font-weight: bold;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ ".status-inactivo, .ocupado {" _ $c(13,10)
    Set css = css _ "    color: #e74c3c;" _ $c(13,10)
    Set css = css _ "    font-weight: bold;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Quit css
}

}
