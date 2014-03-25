<form action="upload.php" method="post" enctype="multipart/form-data">
<fieldset>
<legend>Image Upload</legend>
<label for="userFile">Small image to upload: </label>
<input type="file" size="40" name="userFile" id="userFile"/><br />
browser:<input type="text" size="40" name="browser" id="browser"/><br />
algo: <input type="text" size="40" name="algo" id="algo"/><br />
graphsrc:<textarea name="graph_src" width="80" height="80"></textarea>
<br />
<br />
<input type="submit" value="Upload File" />
</fieldset>
</form>
