<incluir archivo="Header">
<incluir archivo="Menu">
<div class="container">
<h3>Alta de usuarios</h3>
<form id="usuarios">
	<label>Clave</label>
	<input type="text" class="form-control" name="clave">
	<label>Nombre</label>
	<input type="text" class="form-control" name="nombre">
	<label>Password</label>
	<input type="text" class="form-control" name="password">
	<label>Perfil</label>
	<select name="perfil" class="form-control">
		<option value="1">Administrador</option>
		<option value="2">Operativo</option>
		<option value="3">Vendedor</option>
	</select>

</form>
<br>
<p><a class="btn btn-primary btn-md" href="#" role="button" onclick="guardar()">Guardar</a></p>
</div>
<script type="text/javascript">
function guardar() {
	sincco.consumirAPI('POST','{BASE_URL}usuarios/apiPost',$("#usuarios").serializeJSON())
	.done(function(data) {
		if(data.respuesta)
			window.location = '{BASE_URL}usuarios'
	}).fail(function(jqXHR, textStatus, errorThrown) {
		console.log(errorThrown)
	})	
}
</script>
<incluir archivo="Footer">