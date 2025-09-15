/// Estilos para modales de la aplicación PETS
Class Demo.PETS.CSS.Modals Extends %CSP.Page [ Not ProcedureBlock ]
{

/// Generar CSS para modales
ClassMethod GenerateCSS() As %String
{
    Set css = ""
    Set css = css _ "/* ==================================" _ $c(13,10)
    Set css = css _ "   ESTILOS MODALES - SISTEMA PETS" _ $c(13,10)
    Set css = css _ "   ================================== */" _ $c(13,10)
    Set css = css _ $c(13,10)
    
    Set css = css _ ".modal {" _ $c(13,10)
    Set css = css _ "    display: none;" _ $c(13,10)
    Set css = css _ "    position: fixed;" _ $c(13,10)
    Set css = css _ "    z-index: 1000;" _ $c(13,10)
    Set css = css _ "    left: 0;" _ $c(13,10)
    Set css = css _ "    top: 0;" _ $c(13,10)
    Set css = css _ "    width: 100%;" _ $c(13,10)
    Set css = css _ "    height: 100%;" _ $c(13,10)
    Set css = css _ "    background-color: rgba(0,0,0,0.5);" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ ".modal-content {" _ $c(13,10)
    Set css = css _ "    background-color: #fefefe;" _ $c(13,10)
    Set css = css _ "    margin: 10% auto;" _ $c(13,10)
    Set css = css _ "    padding: 0;" _ $c(13,10)
    Set css = css _ "    border-radius: 8px;" _ $c(13,10)
    Set css = css _ "    width: 80%;" _ $c(13,10)
    Set css = css _ "    max-width: 500px;" _ $c(13,10)
    Set css = css _ "    box-shadow: 0 4px 20px rgba(0,0,0,0.3);" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ ".modal-header {" _ $c(13,10)
    Set css = css _ "    padding: 20px;" _ $c(13,10)
    Set css = css _ "    background-color: #e74c3c;" _ $c(13,10)
    Set css = css _ "    color: white;" _ $c(13,10)
    Set css = css _ "    border-radius: 8px 8px 0 0;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ ".modal-header h2 {" _ $c(13,10)
    Set css = css _ "    margin: 0;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Quit css
}

/// Estilos adicionales para modales
ClassMethod GenerateModalExtras() As %String
{
    Set css = ""
    Set css = css _ ".close {" _ $c(13,10)
    Set css = css _ "    float: right;" _ $c(13,10)
    Set css = css _ "    font-size: 28px;" _ $c(13,10)
    Set css = css _ "    font-weight: bold;" _ $c(13,10)
    Set css = css _ "    cursor: pointer;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ ".close:hover {" _ $c(13,10)
    Set css = css _ "    color: #f1c40f;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ ".modal-body {" _ $c(13,10)
    Set css = css _ "    padding: 20px;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ ".modal-footer {" _ $c(13,10)
    Set css = css _ "    padding: 15px 20px;" _ $c(13,10)
    Set css = css _ "    text-align: right;" _ $c(13,10)
    Set css = css _ "    border-top: 1px solid #ddd;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Set css = css _ ".btn-primary, .btn-secondary {" _ $c(13,10)
    Set css = css _ "    padding: 10px 20px;" _ $c(13,10)
    Set css = css _ "    margin-left: 10px;" _ $c(13,10)
    Set css = css _ "    border: none;" _ $c(13,10)
    Set css = css _ "    border-radius: 4px;" _ $c(13,10)
    Set css = css _ "    cursor: pointer;" _ $c(13,10)
    Set css = css _ "}" _ $c(13,10)
    
    Quit css
}

}
