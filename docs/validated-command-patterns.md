# Patrones validados de comandos Azure DevOps

## Objetivo
Definir patrones de comando reutilizables para prompts de Azure DevOps cuando la CLI tenga combinaciones fragiles o respuestas engañosas.

## Regla general
- Priorizar comandos y formas de lectura ya validadas en este repo.
- No optimizar salida demasiado pronto si eso introduce combinaciones fragiles.
- No concluir exito solo por exit code `0`; validar payload, conteo o campo esperado.

## Patrones de lectura

### Leer campos de un Work Item
- Comando preferido:
  - `az boards work-item show --org https://dev.azure.com/cat-digital --id <ID> --expand fields --only-show-errors -o json`
- Regla:
  - No combinar `--fields` con `--expand`.
  - Extraer campos desde `fields["<FieldName>"]`.

### Consultas WIQL para listas abiertas
- Patrón preferido:
  1. Ejecutar WIQL para obtener IDs.
  2. Recuperar detalles solo de esos IDs.
  3. Validar que el numero de filas devuelto coincide con el conjunto de IDs esperado.
- Regla:
  - Si WIQL devuelve cero IDs, tratarlo como resultado valido pero explicito, no como fallo silencioso.

## Patrones de escritura

### Crear o actualizar Work Items
- Preferir `az boards work-item create` y `az boards work-item update` cuando exista soporte directo.
- Evitar `az devops invoke --resource workitems` si el entorno reproduce `KeyError: 'type'`.

### JSON y payloads
- Para `--in-file`, escribir JSON sin BOM.
- Para valores con backslashes, usar forward slashes o escape correcto.

## Verificacion posterior
- Despues de cada POST o PATCH, ejecutar una lectura inmediata.
- Verificar una de estas condiciones segun el caso:
  - El campo esperado existe.
  - El ID creado aparece en la lista.
  - El conteo coincide.
  - La relacion creada aparece en la lectura posterior.