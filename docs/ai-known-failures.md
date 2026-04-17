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

## Mantenimiento del repo
- Cuando se descubra un fallo nuevo y repetible, actualizar primero el prompt afectado o la plantilla compartida.
- Registrar el cambio en `changelog/prompts-history.md` con fecha, causa y correccion.
- Si el fallo impacta varias familias de prompts, reflejarlo tambien en esta guia.