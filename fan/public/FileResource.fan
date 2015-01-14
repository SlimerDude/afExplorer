using afIoc
using afBeanUtils
using afReflux
using gfx
using fwt

** (Resource) - 
** Represents a file on the file system.
class FileResource : Resource {

	@Inject private	Explorer			_explorer
	@Inject private	Errors				_errors
	@Inject private	ExplorerCmds		_fileCmds
	@Inject private DefaultFileViews	_defaultViews

	override Uri 	uri
	override Str 	name
	override Image?	icon
	override Str	displayName
			 File	file

	new make(|This|in) : super.make(in) { 
		displayName = file.osPath
	}

	override Type? defaultView() {
		_defaultViews[file.ext]
	}
	
	override Menu populatePopup(Menu m) {
		menu := super.populatePopup(m)
		
		if (!file.isDir) {
			addCmd(menu, _fileCmds.openFileCmd(file))
			
			fileExt := file.ext.lower
			prefs	:= _explorer.preferences
			actions := prefs.fileActions.findAll { it.ext == fileExt }
			actions.each |action| {
				launcher := prefs.fileLaunchers.find { it.id == action.launcherId }
				if (launcher == null)
					_errors.add(ArgNotFoundErr("Could not find a launcher with id '${action.launcherId}'", prefs.fileLaunchers.map { it.id }))
				else
					addCmd(menu, _fileCmds.actionFileCmd(file, action, launcher))
			}

			menu.addSep
		}		

		addCmd(menu, _fileCmds.renameFileCmd(file))
		addCmd(menu, _fileCmds.deleteFileCmd(file))

		menu.addSep
		addCmd(menu, _fileCmds.cutFileCmd(file))
		addCmd(menu, _fileCmds.copyFileCmd(file))
		addCmd(menu, _fileCmds.pasteFileCmd(file))

		menu.addSep
		addCmd(menu, _fileCmds.copyFileNameCmd(file))
		addCmd(menu, _fileCmds.copyFilePathCmd(file))
		addCmd(menu, _fileCmds.copyFileUriCmd(file))

		if (file.isDir) {
			menu.addSep
			addCmd(menu, _fileCmds.newFileCmd(file))
			addCmd(menu, _fileCmds.newFolderCmd(file))
		}
		
		// open
		// open in new tab
		// edit
		// find in files
		// cmd prompt
		// add to zip
		// properties
		
		return menu 
	}
	
	override Void doAction() {
		// show view if there is one 
		if (_defaultViews[file.ext] != null) {
			super.doAction
			return
		}

		if (file.isDir) {
			super.doAction
			return			
		}
		
		// else launch it
		Desktop.launchProgram(uri)
	}
	
	Void addCmd(Menu menu, Command cmd) {
		menu.add(MenuItem.makeCommand(cmd))
	}
}



** (Resource) - 
** Represents a folder on the file system.
class FolderResource : FileResource {
	new make(|This|in) : super.make(in) { }
	override Type? defaultView() {
		FolderView#
	}
}