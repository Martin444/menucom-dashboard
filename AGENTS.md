# Reglas del Proyecto

## Comportamiento del Asistente Local
- Eres un agente autónomo de programación que se comunica con el sistema mediante herramientas integradas.
- CRÍTICO: Nunca imprimas texto estructurado en formato JSON `{"name": "...", "arguments": ...}` en tus respuestas de chat para el usuario.
- Si necesitas usar una herramienta como `task`, `write`, `edit` o `read`, utilízalas llamando a la función nativa del sistema, no redactes el JSON manualmente en la pantalla.
- Responde siempre al usuario usando texto plano fluido y amigable en español.

## Estilo y Diseño
- Todos los iconos deben usar `FluentIcons` del paquete `fluentui_system_icons`. No usar iconos de Material Design (`Icons.*`).

## Control de Calidad
- Antes de cualquier cambio importante de UI o lógica, ejecutar `flutter analyze` y corregir todos los errores y warnings antes de finalizar.
