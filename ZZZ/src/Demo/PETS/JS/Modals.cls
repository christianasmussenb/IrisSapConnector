/// JavaScript para modales de la aplicación PETS
Class Demo.PETS.JS.Modals Extends %CSP.Page [ Not ProcedureBlock ]
{

/// Generar JavaScript para modales
ClassMethod GenerateJS() As %String
{
    Set js = ""
    Set js = js _ "/* ==================================" _ $c(13,10)
    Set js = js _ "   JAVASCRIPT MODALES - SISTEMA PETS" _ $c(13,10)
    Set js = js _ "   ================================== */" _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Set js = js _ "// Extensión del objeto PETS para modales" _ $c(13,10)
    Set js = js _ "PETS.modals = {" _ $c(13,10)
    Set js = js _ "    show: function(modalId) {" _ $c(13,10)
    Set js = js _ "        const modal = document.getElementById(modalId);" _ $c(13,10)
    Set js = js _ "        if (modal) {" _ $c(13,10)
    Set js = js _ "            modal.style.display = 'block';" _ $c(13,10)
    Set js = js _ "        }" _ $c(13,10)
    Set js = js _ "    }," _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Set js = js _ "    hide: function(modalId) {" _ $c(13,10)
    Set js = js _ "        const modal = document.getElementById(modalId);" _ $c(13,10)
    Set js = js _ "        if (modal) {" _ $c(13,10)
    Set js = js _ "            modal.style.display = 'none';" _ $c(13,10)
    Set js = js _ "        }" _ $c(13,10)
    Set js = js _ "    }," _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Set js = js _ "    showResult: function(data, modalId) {" _ $c(13,10)
    Set js = js _ "        modalId = modalId || 'resultModal';" _ $c(13,10)
    Set js = js _ "        const modal = document.getElementById(modalId);" _ $c(13,10)
    Set js = js _ "        const modalBody = document.getElementById('modalBody');" _ $c(13,10)
    Set js = js _ "        const modalTitle = document.getElementById('modalTitle');" _ $c(13,10)
    Set js = js _ "        " _ $c(13,10)
    Set js = js _ "        if (!modal || !modalBody || !modalTitle) return;" _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Set js = js _ "        if (data.error) {" _ $c(13,10)
    Set js = js _ "            modalTitle.textContent = 'Error en el Registro';" _ $c(13,10)
    Set js = js _ "            modalBody.innerHTML = `" _ $c(13,10)
    Set js = js _ "                <div class='error-icon'>❌</div>" _ $c(13,10)
    Set js = js _ "                <p style='text-align: center; color: #e74c3c; font-weight: bold;'>${data.error}</p>" _ $c(13,10)
    Set js = js _ "            `;" _ $c(13,10)
    Set js = js _ "        } else {" _ $c(13,10)
    Set js = js _ "            modalTitle.textContent = '¡Registro Exitoso!';" _ $c(13,10)
    Set js = js _ "            modalBody.innerHTML = `" _ $c(13,10)
    Set js = js _ "                <div style='text-align: center;'>" _ $c(13,10)
    Set js = js _ "                    <div style='font-size: 48px; margin-bottom: 15px;'>🐾</div>" _ $c(13,10)
    Set js = js _ "                    <h3 style='color: #27ae60; margin: 10px 0;'>Información de la Mascota Registrada</h3>" _ $c(13,10)
    Set js = js _ "                    <div style='text-align: left; max-width: 400px; margin: 0 auto;'>" _ $c(13,10)
    Set js = js _ "                        <p><strong>ID:</strong> ${data.id || 'N/A'}</p>" _ $c(13,10)
    Set js = js _ "                        <p><strong>UserID:</strong> ${data.userid || 'N/A'}</p>" _ $c(13,10)
    Set js = js _ "                        <p><strong>Nombre:</strong> ${data.nombre || 'N/A'}</p>" _ $c(13,10)
    Set js = js _ "                        <p><strong>Raza:</strong> ${data.raza || 'N/A'}</p>" _ $c(13,10)
    Set js = js _ "                        <p><strong>Edad:</strong> ${data.edad || 'N/A'} años</p>" _ $c(13,10)
    Set js = js _ "                        <p><strong>Peso:</strong> ${data.peso || 'N/A'} kg</p>" _ $c(13,10)
    Set js = js _ "                        <p><strong>Tamaño:</strong> ${data.tamaño || data['tamaño'] || 'N/A'}</p>" _ $c(13,10)
    Set js = js _ "                        <p><strong>Color:</strong> ${data.color || 'N/A'}</p>" _ $c(13,10)
    Set js = js _ "                        <p><strong>Dueño:</strong> ${data.owner || 'N/A'}</p>" _ $c(13,10)
    Set js = js _ "                        <p><strong>Estado:</strong> Activo</p>" _ $c(13,10)
    Set js = js _ "                    </div>" _ $c(13,10)
    Set js = js _ "                    <p style='color: #27ae60; font-weight: bold; margin-top: 20px;'>Mascota registrada exitosamente!</p>" _ $c(13,10)
    Set js = js _ "                </div>" _ $c(13,10)
    Set js = js _ "            `;" _ $c(13,10)
    Set js = js _ "        }" _ $c(13,10)
    Set js = js _ "        " _ $c(13,10)
    Set js = js _ "        this.show(modalId);" _ $c(13,10)
    Set js = js _ "    }," _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Set js = js _ "    setupCloseHandlers: function(modalId) {" _ $c(13,10)
    Set js = js _ "        modalId = modalId || 'resultModal';" _ $c(13,10)
    Set js = js _ "        const modal = document.getElementById(modalId);" _ $c(13,10)
    Set js = js _ "        " _ $c(13,10)
    Set js = js _ "        // Click fuera del modal para cerrar" _ $c(13,10)
    Set js = js _ "        window.addEventListener('click', function(event) {" _ $c(13,10)
    Set js = js _ "            if (event.target === modal) {" _ $c(13,10)
    Set js = js _ "                PETS.modals.hide(modalId);" _ $c(13,10)
    Set js = js _ "            }" _ $c(13,10)
    Set js = js _ "        });" _ $c(13,10)
    Set js = js _ "    }" _ $c(13,10)
    Set js = js _ "};" _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Quit js
}

}
