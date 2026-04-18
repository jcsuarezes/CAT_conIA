# Fallos conocidos de IA y Azure DevOps CLI

## Objetivo
Documentar errores repetibles, limites conocidos y patrones operativos validados para que los prompts y las ejecuciones futuras no repitan el mismo ensayo-error.

## Reglas operativas
- No asumir que el modelo aprende automaticamente de una falla anterior; el aprendizaje debe quedar documentado en prompts, changelog o memoria persistente.
- No considerar exito una ejecucion solo porque el exit code sea `0`; validar tambien el contenido devuelto.
- Preferir patrones validados de Azure DevOps CLI sobre atajos de salida minima cuando la CLI tenga combinaciones fragiles.

## Azure DevOps CLI

### #1. `az boards work-item show`
- No combinar `--fields` con `--expand`.
- Para leer campos concretos como `System.WorkItemType`, usar `--expand fields -o json` y extraer el valor desde `fields["System.WorkItemType"]`.
- Si stdout llega vacio, no concluir exito hasta verificar el JSON devuelto o una consulta explicita.

### #2. `az devops invoke`
- Para payloads con `--in-file`, escribir JSON sin BOM.
- Para rutas con backslashes en JSON, usar forward slashes o escapar adecuadamente.
- No confiar en un HTTP 200 como prueba suficiente en operaciones de escritura; verificar con una lectura posterior.

### #3. `Microsoft.VSTS.TCM.Steps` renderiza vacio en Test Plans
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

### 7. `$PID` es una variable reservada en PowerShell
- **Issue**: Usar `$pid` o `$PID` como nombre de variable en PowerShell causa `VariableNotWritable` porque es una variable interna protegida del proceso.
- **Symptom**: `Cannot overwrite variable PID because it is read-only or constant.`
- **Fix**: Nunca usar `$pid` como variable en scripts. Usar nombres alternativos como `$planId`, `$planIdCurrent`, `$currentPlanId`, etc.

### 8. Scripts largos en una sola línea se truncan en el terminal
- **Issue**: Cuando un script de una sola línea supera cierto largo se trunca al pegarlo en el terminal, produciendo errores de sintaxis o ejecución parcial.
- **Symptom**: El script se corta sin mensaje de error; el comando nunca completa o produce resultados parciales.
- **Fix**: Guardar siempre el script como archivo `.ps1` y ejecutarlo con `& .\scripts\nombre-script.ps1`. No confiar en pegado inline para scripts que superen 500 caracteres.

### 9. Búsqueda exhaustiva de suites a través de todos los planes causa timeout
- **Issue**: Intentar escanear más de 200 Test Plans con paginación de suites en un solo script PowerShell tarda varios minutos y supera el timeout disponible.
- **Symptom**: El script no produce output JSON final; la terminal queda en ejecución y el resultado nunca llega.
- **Root cause**: La API de suites no acepta `suiteId` como filtro sin `planId`; se requiere iterar planId por planId.
- **Fix**: Requerir que el usuario proporcione `planId` junto con `suiteId` cuando quiere reutilizar una suite. No intentar descubrir el plan automáticamente en entornos con 100+ planes.
- **Prompt impact**: `create-webservices-test-cases-from-user-story.md` y `resolve-or-create-requirement-based-suite.md` deben solicitar ambos IDs juntos.

### 10. El plan ID provisto puede no existir en la organización
- **Issue**: Si el usuario proporciona un `Test Plan ID` incorrecto, el API devuelve `Test plan XXXXX not found` para todas las operaciones dependientes.
- **Fix**: Hacer lookup directo del plan con `az devops invoke --area testplan --resource plans --route-parameters planId=<ID>` como primer paso de validación antes de cualquier operación de suite o test case.
- **Fail fast rule**: Si el plan no existe, detener inmediatamente y reportar BLOCKED con el mensaje exacto del API.

### 11. Confusión recurrente entre `planId` y `suiteId` al copiar desde URL
- **Issue**: En vistas de Test Plans, el encabezado puede mostrar un ID de suite/contenedor mientras el `planId` real solo aparece en la URL.
- **Symptom**: Se usa un ID correcto pero en el parámetro incorrecto y el API responde `Test plan XXXXX not found`.
- **Fix**: Tomar ambos parámetros desde URL completa y validar en un solo GET: `planId=<plan>&suiteId=<suite>`.
- **Guardrail**: No inferir plan desde el nombre visual del encabezado.

### 12. Exit code enmascarado por pipes en PowerShell
- **Issue**: Comandos como `az ... | Select-Object -First N` pueden dejar un `exit code` engañoso de la tubería y ocultar el resultado real de `az`.
- **Symptom**: Se interpreta éxito por `Exit Code: 0` aunque el cuerpo contiene `ERROR`.
- **Fix**: Para validación técnica, ejecutar primero el comando sin pipe y capturar `$LASTEXITCODE` inmediatamente.
- **Guardrail**: Evaluar siempre `exit code` y contenido de salida.

### 13. Validación de `description` en Steps XML con conteos inestables
- **Issue**: En PowerShell, contar nodos XML sin materializar colección (`.Count` sobre objeto único) puede devolver vacío y producir falsos FAIL.
- **Symptom**: `descriptionNodesPass=false` aunque el XML persistido renderiza correctamente en Test Plans.
- **Fix**: Materializar con `@(...)` antes de `.Count` o validar por patrón XML persistido + parse estructural por step.
- **Guardrail**: Evitar declarar `BLOCKED` por conteo ambiguo sin readback corroborado.

### 14. Verificación de membresía de suite con matcher demasiado amplio
- **Issue**: Buscar cualquier `"id":<TC_ID>` en JSON completo puede dar falsos positivos/negativos por colisiones de nodos no relacionados.
- **Fix**: Validar presencia en rutas específicas (`testCase.id`, `workItem.id`, `testCaseId`) o recorrer nodos objetivo.
- **Guardrail**: Confirmar cada TC creado con una verificación dirigida por estructura, no por texto global.

## Mantenimiento del repo
- Cuando se descubra un fallo nuevo y repetible, actualizar primero el prompt afectado o la plantilla compartida.
- Registrar el cambio en `changelog/prompts-history.md` con fecha, causa y correccion.
- Si el fallo impacta varias familias de prompts, reflejarlo tambien en esta guia.