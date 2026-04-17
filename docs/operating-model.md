# Modelo operativo (Markdown-only)

## Flujo estándar
1. Seleccionar prompt desde `catalog/index.md`.
2. Completar bloque de `Inputs` (sin cambiar configuración fija de organización).
3. Ejecutar prompt en el asistente.
4. Revisar `Validation Checklist`.
5. Registrar mejoras en `changelog/prompts-history.md`.

## Reglas del equipo
- Prompts: inglés.
- Documentación y coordinación: español.
- Para updates, comenzar con `dry run`.
- Cualquier cambio de plantilla sube versión en historial.
- Organización fija para prompts Azure DevOps: `https://dev.azure.com/cat-digital`.
- Todo prompt nuevo debe agregarse a `catalog/index.md` antes de considerarse activo.

## Gobierno de scripts
- El flujo oficial del framework es `prompt-first`.
- `scripts/` se usa como soporte operacional/legado y no debe crecer por cada caso de uso.
- Evitar scripts específicos por tipo de historia (UI, Webservices, Data) si el comportamiento puede quedar en prompts.
- Si un caso exige automatización, priorizar un flujo reusable único y documentar alcance, riesgo y retiro en `changelog/prompts-history.md`.
- Cuando exista contradicción entre script y prompt, prevalece el prompt y se corrige el script o se retira.

## Criterio de incorporación de automatización
1. Confirmar que el prompt no puede cubrir el caso de forma estable.
2. Validar que la automatización es reusable (no de una sola historia).
3. Definir owner técnico y fecha tentativa de retiro.
4. Registrar el cambio en `changelog/prompts-history.md`.

## Criterios de calidad
- Claridad en entradas obligatorias.
- Salidas auditables (old/new + rationale).
- Compatibilidad markdown en Azure DevOps.
- Sin exposición de secretos.
