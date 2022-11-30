# plantuml

安装

	sudo emerge -v media-gfx/plantuml

使用

	java -jar /usr/share/plantuml/lib/plantuml.jar sequenceDiagram.txt
	其中sequenceDiagram.txt内容如下
	@startuml
	Alice -> Bob: test
	@enduml
