class arSync extends LocalConnection {

	public var connection:String = '', onLoad:Function = function(){};
	private var Name:String = '', connectionId:Number = 0, panels = null;

	public function arSync(Name:String, panels:Array){
		super();
		this.Name = Name;
		this.connection = '_' + Name;

		if (panels) {
			this.panels = {};
			for(var i=0; i<panels.length; i++) this.panels[panels[i]] = false;
		}

		this.checkLoad();
		this.send(this.connection, "emptyFunction");
	}
	public function sendCommand(id, commad, args){
		this.send('_' + id + (this.connectionId || ''), commad, args);
	}

	private function checkLoad(){
		var _ = this;
		if (_root.getBytesLoaded() >= _root.getBytesTotal()){
			this.rootLoaded = true;
			this.ready();
		}
		else setTimeout(function(){_.checkLoad()}, 100);
    }
	private function ready(isPanel:Boolean){
		if(this.rootLoaded && this.connected){
			if (this.fullLoad||isPanel) {
				for(var i in this.panels) this.sendCommand(i, 'ready', true);
				this.onLoad();
			}
			else this.pingPanels();
		}
	}
	private function pingPanels(){
		if (!this.panels) return;

		var _ = this;
		this.fullLoad = true;
		for(var i in this.panels) if (!this.panels[i]) {
			this.sendCommand(i, 'ping')
			this.fullLoad = false;
		}

		if (this.fullLoad) this.ready();
		else setTimeout(function(){_.pingPanels()}, 100);
	}
	private function ping(){this.sendCommand('master', 'confirm', this.Name)}
	private function confirm(id:String){this.panels[id] = true}
	private function emptyFunction(){}

	function allowDomain(sendingDomain:String){return true}
	function onStatus(infoObject:Object){
		switch (infoObject.level) {
			case 'status':
				this.connectionId++;
				this.connection = '_' + this.Name + this.connectionId;
				this.send(this.connection, "emptyFunction");
				break;
			case 'error':
				this.connect(this.connection);
				this.connected = true;
				this.ready();
				this.onStatus = null;
				break;
		}
	}
}