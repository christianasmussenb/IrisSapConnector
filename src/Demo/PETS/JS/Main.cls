/// Clase principal JavaScript que unifica todos los scripts PETS
Class Demo.PETS.JS.Main Extends %CSP.Page [ Not ProcedureBlock ]
{

/// Generar todo el JavaScript unificado
ClassMethod GenerateAllJS() As %String
{
    Set js = ""
    
    // Combinar todos los scripts
    Set js = js _ ##class(Demo.PETS.JS.Base).GenerateJS()
    Set js = js _ $c(13,10)
    Set js = js _ ##class(Demo.PETS.JS.Modals).GenerateJS()
    Set js = js _ $c(13,10)
    Set js = js _ ##class(Demo.PETS.JS.Forms).GenerateJS()
    Set js = js _ $c(13,10)
    
    // Agregar inicialización automática
    Set js = js _ "// Inicialización automática cuando el DOM esté listo" _ $c(13,10)
    Set js = js _ "document.addEventListener('DOMContentLoaded', function() {" _ $c(13,10)
    Set js = js _ "    console.log('PETS JavaScript System initialized');" _ $c(13,10)
    Set js = js _ "    " _ $c(13,10)
    Set js = js _ "    // Configurar modales" _ $c(13,10)
    Set js = js _ "    PETS.modals.setupCloseHandlers('resultModal');" _ $c(13,10)
    Set js = js _ "    " _ $c(13,10)
    Set js = js _ "    // Configurar formularios según el tipo de página" _ $c(13,10)
    Set js = js _ "    if (document.getElementById('petForm')) {" _ $c(13,10)
    Set js = js _ "        PETS.forms.setupPetForm();" _ $c(13,10)
    Set js = js _ "    }" _ $c(13,10)
    Set js = js _ "    " _ $c(13,10)
    Set js = js _ "    if (document.getElementById('walkerForm')) {" _ $c(13,10)
    Set js = js _ "        PETS.forms.setupWalkerForm();" _ $c(13,10)
    Set js = js _ "    }" _ $c(13,10)
    Set js = js _ "    " _ $c(13,10)
    Set js = js _ "    if (document.getElementById('ownerForm')) {" _ $c(13,10)
    Set js = js _ "        PETS.forms.setupOwnerForm();" _ $c(13,10)
    Set js = js _ "    }" _ $c(13,10)
    Set js = js _ "});" _ $c(13,10)
    Set js = js _ $c(13,10)
    
    // Agregar funciones legacy para compatibilidad
    Set js = js _ "// Funciones legacy para compatibilidad" _ $c(13,10)
    Set js = js _ "function showResultModal(data) {" _ $c(13,10)
    Set js = js _ "    PETS.modals.showResult(data);" _ $c(13,10)
    Set js = js _ "}" _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Quit js
}

/// Servir JavaScript via web
ClassMethod OnPage() As %Status
{
    Set %response.ContentType = "application/javascript"
    Set %response.CharSet = "UTF-8"
    Write ..GenerateAllJS()
    Quit $$$OK
}

}
