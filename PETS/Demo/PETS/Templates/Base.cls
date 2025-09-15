/// Templates base para la aplicación PETS
Class Demo.PETS.Templates.Base Extends %CSP.Page [ Not ProcedureBlock ]
{

/// Generar header HTML común
ClassMethod GenerateHeader(title As %String = "Sistema PETS", additionalHead As %String = "") As %String
{
    Set html = ""
    Set html = html _ "<!DOCTYPE html>" _ $c(13,10)
    Set html = html _ "<html><head><title>" _ title _ "</title>" _ $c(13,10)
    Set html = html _ "<meta charset='utf-8'>" _ $c(13,10)
    Set html = html _ ##class(Demo.REST).GenerateCSSLink() _ $c(13,10)
    If additionalHead '= "" {
        Set html = html _ additionalHead _ $c(13,10)
    }
    Set html = html _ "</head><body>" _ $c(13,10)
    
    Quit html
}

/// Generar footer HTML común
ClassMethod GenerateFooter(additionalScript As %String = "") As %String
{
    Set html = ""
    
    // JavaScript modular
    Set html = html _ ##class(Demo.REST).GenerateJSLink() _ $c(13,10)
    
    // Scripts adicionales si se especifican
    If additionalScript '= "" {
        Set html = html _ additionalScript _ $c(13,10)
    }
    
    Set html = html _ "</body></html>" _ $c(13,10)
    
    Quit html
}

/// Generar contenedor principal
ClassMethod GenerateContainer(content As %String, title As %String = "") As %String
{
    Set html = ""
    Set html = html _ "<div class='container'>" _ $c(13,10)
    
    If title '= "" {
        Set html = html _ "<h1>" _ title _ "</h1>" _ $c(13,10)
    }
    
    Set html = html _ content _ $c(13,10)
    Set html = html _ "</div>" _ $c(13,10)
    
    Quit html
}

/// Generar página completa
ClassMethod GeneratePage(title As %String, content As %String, additionalHead As %String = "", additionalScript As %String = "") As %String
{
    Set html = ""
    Set html = html _ ..GenerateHeader(title, additionalHead)
    Set html = html _ ..GenerateContainer(content, "")
    Set html = html _ ..GenerateFooter(additionalScript)
    
    Quit html
}

/// Generar botón de navegación
ClassMethod GenerateNavButton(url As %String, text As %String, style As %String = "btn-secondary") As %String
{
    Set classes = ""
    If style = "btn-primary" {
        Set classes = "background:#3498db; color:white;"
    } ElseIf style = "btn-secondary" {
        Set classes = "background:#95a5a6; color:white;"
    } ElseIf style = "btn-success" {
        Set classes = "background:#27ae60; color:white;"
    } ElseIf style = "btn-back" {
        Set classes = "background:#95a5a6; color:white;"
    } Else {
        Set classes = style
    }
    
    Quit "<a href='" _ url _ "' style='" _ classes _ " padding:12px 20px; text-decoration:none; border-radius:4px; margin:10px 5px; display:inline-block;'>" _ text _ "</a>"
}

/// Generar breadcrumbs de navegación
ClassMethod GenerateBreadcrumbs(items As %String) As %String
{
    Set html = ""
    Set html = html _ "<div style='margin-bottom: 20px; padding: 10px; background: #f8f9fa; border-radius: 4px;'>" _ $c(13,10)
    Set html = html _ "<nav style='font-size: 14px; color: #6c757d;'>" _ $c(13,10)
    Set html = html _ items _ $c(13,10)
    Set html = html _ "</nav>" _ $c(13,10)
    Set html = html _ "</div>" _ $c(13,10)
    
    Quit html
}

}
