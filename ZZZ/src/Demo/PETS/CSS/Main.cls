/// Clase principal CSS que unifica todos los estilos PETS
Class Demo.PETS.CSS.Main Extends %CSP.Page [ Not ProcedureBlock ]
{

/// Generar todo el CSS unificado
ClassMethod GenerateAllCSS() As %String
{
    Set css = ""
    
    // Combinar todos los estilos
    Set css = css _ ##class(Demo.PETS.CSS.Base).GenerateCSS()
    Set css = css _ $c(13,10)
    Set css = css _ ##class(Demo.PETS.CSS.Forms).GenerateCSS()
    Set css = css _ $c(13,10)
    Set css = css _ ##class(Demo.PETS.CSS.Tables).GenerateCSS()
    Set css = css _ $c(13,10)
    Set css = css _ ##class(Demo.PETS.CSS.Modals).GenerateCSS()
    Set css = css _ $c(13,10)
    Set css = css _ ##class(Demo.PETS.CSS.Modals).GenerateModalExtras()
    
    Quit css
}

/// Servir CSS via web
ClassMethod OnPage() As %Status
{
    Set %response.ContentType = "text/css"
    Set %response.CharSet = "UTF-8"
    Write ..GenerateAllCSS()
    Quit $$$OK
}

}
