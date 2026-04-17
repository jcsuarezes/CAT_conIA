# Fallos conocidos de IA y Azure DevOps CLI

## Objetivo
Documentar errores repetibles, limites conocidos y patrones operativos validados para que los prompts y las ejecuciones futuras no repitan el mismo ensayo-error.

## Reglas operativas
- No asumir que el modelo aprende automaticamente de una falla anterior; el aprendizaje debe quedar documentado en prompts, changelog o memoria persistente.
- No considerar exito una ejecucion solo porque el exit code sea `0`; validar tambien el contenido devuelto.
- Preferir patrones validados de Azure DevOps CLI sobre atajos de salida minima cuando la CLI tenga combinaciones fragiles.

## Azure DevOps CLI

### `az boards work-item show`
- No combinar `--fields` con `--expand`.
- Para leer campos concretos como `System.WorkItemType`, usar `--expand fields -o json` y extraer el valor desde `fields["System.WorkItemType"]`.
- Si stdout llega vacio, no concluir exito hasta verificar el JSON devuelto o una consulta explicita.

### `az devops invoke`
- Para payloads con `--in-file`, escribir JSON sin BOM.
- Para rutas con backslashes en JSON, usar forward slashes o escapar adecuadamente.
- No confiar en un HTTP 200 como prueba suficiente en operaciones de escritura; verificar con una lectura posterior.

### `Microsoft.VSTS.TCM.Steps` renderiza vacio en Test Plans
- Sintoma: el campo `Microsoft.VSTS.TCM.Steps` queda poblado en el Work Item, pero Azure Test Plans no muestra `Actions` ni `Expected Results`.
- Causa confirmada: generar XML con `ValidateStep`, atributos sin comillas persistidas, o sin nodo `<description/>` puede dejar el grid vacio aunque el update devuelva exito.
- Causa adicional confirmada: validaciones de solo "marcadores de texto" (por ejemplo, buscar URL o nombres de campos) pueden dar PASS falso aunque la estructura por step no sea renderizable en la grilla.
- Patron validado: usar `az boards work-item update --field "Microsoft.VSTS.TCM.Steps=<xml>"` con XML de este estilo:
	- `<steps id='0' last='N'>...`
	- `<step id='2' type='ActionStep'>...<description/></step>`
- Verificacion obligatoria: despues del update, leer el campo y validar que siga conteniendo `type='ActionStep'`, atributos con comillas simples y al menos un `<description/>`.
- Verificacion estructural obligatoria: por cada `<step ...>`, validar exactamente 2 nodos `parameterizedString` (Action + Expected Result) y `<description/>`; no basta con validacion por texto.
- No considerar valido un update de Steps solo porque el texto incluya la URL o el contenido esperado; validar tambien compatibilidad de renderizado.
- Riesgo adicional confirmado en PowerShell: pasar expresiones indexadas o colecciones no materializadas directamente al helper de XML puede terminar en `$Steps.Count = 0` y persistir `<steps id='0' last='0'></steps>`.
- Mitigacion: materializar siempre la lista de pasos en una variable array explicita antes de llamar al generador XML y rechazar cualquier readback vacio o con `last='0'`.

## Mantenimiento del repo
- Cuando se descubra un fallo nuevo y repetible, actualizar primero el prompt afectado o la plantilla compartida.
- Registrar el cambio en `changelog/prompts-history.md` con fecha, causa y correccion.
- Si el fallo impacta varias familias de prompts, reflejarlo tambien en esta guia.