/// Templates para modales de la aplicación PETS
Class Demo.PETS.Templates.Modals Extends %CSP.Page [ Not ProcedureBlock ]
{

/// Generar modal genérico
ClassMethod GenerateModal(modalId As %String, title As %String = "Modal", showCloseButton As %Boolean = 1, customButtons As %String = "") As %String
{
    Set html = ""
    Set html = html _ "<!-- Modal -->" _ $c(13,10)
    Set html = html _ "<div id='" _ modalId _ "' class='modal'>" _ $c(13,10)
    Set html = html _ "<div class='modal-content'>" _ $c(13,10)
    
    // Header del modal
    Set html = html _ "<div class='modal-header'>" _ $c(13,10)
    If showCloseButton {
        Set html = html _ "<span class='close' onclick=""PETS.modals.hide('" _ modalId _ "')"">&times;</span>" _ $c(13,10)
    }
    Set html = html _ "<h2 id='" _ modalId _ "Title'>" _ title _ "</h2>" _ $c(13,10)
    Set html = html _ "</div>" _ $c(13,10)
    
    // Body del modal
    Set html = html _ "<div class='modal-body' id='" _ modalId _ "Body'>" _ $c(13,10)
    Set html = html _ "<!-- Contenido dinámico -->" _ $c(13,10)
    Set html = html _ "</div>" _ $c(13,10)
    
    // Footer del modal
    Set html = html _ "<div class='modal-footer'>" _ $c(13,10)
    If customButtons '= "" {
        Set html = html _ customButtons _ $c(13,10)
    } Else {
        Set html = html _ "<button class='btn-secondary' onclick=""PETS.modals.hide('" _ modalId _ "')"">Cerrar</button>" _ $c(13,10)
    }
    Set html = html _ "</div>" _ $c(13,10)
    
    Set html = html _ "</div>" _ $c(13,10)
    Set html = html _ "</div>" _ $c(13,10)
    
    Quit html
}

/// Generar modal de resultado para formularios
ClassMethod GenerateResultModal(formType As %String = "registro") As %String
{
    Set customButtons = ""
    Set customButtons = customButtons _ "<button id='modalClose' class='btn-secondary' onclick=""PETS.modals.hide('resultModal')"">Cerrar</button>" _ $c(13,10)
    
    If formType = "pet" {
        Set customButtons = customButtons _ "<button id='modalNew' class='btn-primary' onclick=""PETS.forms.resetForm('petForm')"">Registrar Otra Mascota</button>" _ $c(13,10)
    } ElseIf formType = "walker" {
        Set customButtons = customButtons _ "<button id='modalNew' class='btn-primary' onclick=""PETS.forms.resetForm('walkerForm')"">Registrar Otro Paseador</button>" _ $c(13,10)
    } ElseIf formType = "owner" {
        Set customButtons = customButtons _ "<button id='modalNew' class='btn-primary' onclick=""PETS.forms.resetForm('ownerForm')"">Registrar Otro Dueño</button>" _ $c(13,10)
    }
    
    Quit ..GenerateModal("resultModal", "Resultado del Registro", 1, customButtons)
}

/// Generar modal de confirmación
ClassMethod GenerateConfirmModal() As %String
{
    Set customButtons = ""
    Set customButtons = customButtons _ "<button id='confirmCancel' class='btn-secondary' onclick=""PETS.modals.hide('confirmModal')"">Cancelar</button>" _ $c(13,10)
    Set customButtons = customButtons _ "<button id='confirmOk' class='btn-primary'>Confirmar</button>" _ $c(13,10)
    
    Quit ..GenerateModal("confirmModal", "Confirmar Acción", 1, customButtons)
}

/// Generar modal de información
ClassMethod GenerateInfoModal() As %String
{
    Quit ..GenerateModal("infoModal", "Información", 1, "<button class='btn-primary' onclick=""PETS.modals.hide('infoModal')"">Aceptar</button>")
}

/// Generar todos los modales comunes
ClassMethod GenerateAllModals(formType As %String = "") As %String
{
    Set html = ""
    Set html = html _ ..GenerateResultModal(formType) _ $c(13,10)
    Set html = html _ ..GenerateConfirmModal() _ $c(13,10)
    Set html = html _ ..GenerateInfoModal() _ $c(13,10)
    
    Quit html
}

}
