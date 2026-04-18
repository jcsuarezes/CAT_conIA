# Patrones validados de comandos Azure DevOps

## Objetivo
Definir patrones de comando reutilizables para prompts de Azure DevOps cuando la CLI tenga combinaciones fragiles o respuestas engañosas.

## Regla general
- Priorizar comandos y formas de lectura ya validadas en este repo.
- No optimizar salida demasiado pronto si eso introduce combinaciones fragiles.
- No concluir exito solo por exit code `0`; validar payload, conteo o campo esperado.

## Patrones de lectura

### Validar `planId + suiteId` desde URL
- Patrón preferido:
  - `az devops invoke --org https://dev.azure.com/cat-digital --area testplan --resource suites --route-parameters project='Cat Digital' planId=<PLAN_ID> suiteId=<SUITE_ID> --http-method GET --only-show-errors -o json`
- Regla:
  - Tratar `planId` (padre) y `suiteId` (hijo) como obligatorios para reutilizar suite existente.
  - No derivar `planId` desde encabezados visuales; usar la URL de Test Plans.

### Captura de salida sin enmascarar `exit code`
- Patrón preferido:
  1. Ejecutar `az ...` sin pipes para la validación principal.
  2. Capturar `$LASTEXITCODE` inmediatamente.
  3. Si se requiere recorte visual, aplicar formateo en un segundo paso.
- Regla:
  - No usar `| Select-Object` como único mecanismo de evaluación técnica de éxito/fracaso.

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

### Enlace de Test Case a Suite
- Patrón preferido:
  - `az devops invoke --org https://dev.azure.com/cat-digital --area testplan --resource suitetestcase --route-parameters project='Cat Digital' planId=<PLAN_ID> suiteId=<SUITE_ID> --http-method POST --in-file <payload.json> --api-version 7.1-preview --only-show-errors -o json`
- Regla:
  - Verificar cada POST con GET inmediato del mismo `planId + suiteId`.
  - Confirmar membresía buscando IDs en nodos de test case (`testCase.id`, `workItem.id`, `testCaseId`) y no por texto global ambiguo.

## Verificacion posterior
- Despues de cada POST o PATCH, ejecutar una lectura inmediata.
- Verificar una de estas condiciones segun el caso:
  - El campo esperado existe.
  - El ID creado aparece en la lista.
  - El conteo coincide.
  - La relacion creada aparece en la lectura posterior.

### Verificación de Steps XML
- Patrón preferido:
  - Leer `Microsoft.VSTS.TCM.Steps` con `az boards work-item show --expand fields`.
  - Validar por step: 2 `parameterizedString` (Action + Expected Result) y `description`.
- Regla:
  - En PowerShell, usar `@(...)` al contar nodos XML para evitar falsos `Count` vacíos en objetos únicos.