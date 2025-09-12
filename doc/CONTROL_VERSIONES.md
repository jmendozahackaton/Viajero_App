# Control de Versiones - Convenciones

## Estructura de Ramas

master → Versiones de producción
modificaciones/implementar → Integración de features

## Convención de Commits

feat: Nueva funcionalidad
fix: Corrección de bug
docs: Documentación
style: Formato, sin afectar código
refactor: Refactorización de código
test: Adición de tests
chore: Tareas de mantenimiento

## Ejemplos de Commits

feat(auth): implementar login con Firebase Auth
fix(map): corregir carga de marcadores
docs: actualizar README con guía de instalación
refactor(models): optimizar serialización datos

## Flujo de Trabajo
1. Crear rama desde `modificaciones/implementar`: `feature/nombre-funcionalidad`
2. Desarrollar con commits semánticos
3. Hacer pull request a `modificaciones/implementar`
4. Revisión de código y pruebas
5. Merge a `modificaciones/implementar`
6. Deploy a testing environment
7. Crear release branch para producción
8. Merge a `master` con tag de versión

## Estado Actual de Ramas
- **master:** Estable - v1.0.0
- **modificaciones/implementar:** Desarrollo activo

## Colaboración
- Revisión de código obligatoria para merges
- Tests requeridos para nuevas funcionalidades
- Documentación actualizada con cada feature

## PASOS SUBIR A RPOSITORIO GITHUB

# Moverse a la rama de modificaciones
git checkout modificaciones/implementar

git add .
git commit -m "Avance en la implementación"
git push origin modificaciones/implementar

# Ver qué cambió entre master y tu feature
git diff master..modificaciones/implementar

# Fusionar con main/master Volver a main
git checkout master

# Traer los cambios de la feature
git merge modificaciones/implementar