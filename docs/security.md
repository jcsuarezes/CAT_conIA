# Seguridad de credenciales (Azure DevOps)

## Política
- No almacenar `PAT`, tokens, client secrets o contraseñas dentro de este repositorio.
- Solo usar alias/referencias en archivos Markdown del proyecto.

## Ubicación recomendada de secretos (fuera de Git)
- Archivo local externo sugerido: `C:\\Users\\<usuario>\\.prompt-secrets\\azure-devops.local.md`
- Alternativa preferida: gestor de secretos corporativo o Key Vault.

## Buenas prácticas PAT
- Usar scopes mínimos necesarios.
- Definir expiración corta.
- Rotar periódicamente.
- Revocar inmediatamente ante sospecha.

## Checklist operativo
- [ ] No hay tokens en commits
- [ ] No hay tokens en capturas
- [ ] No hay tokens en historial de prompts
- [ ] Aliases actualizados en `profiles/default.md`
