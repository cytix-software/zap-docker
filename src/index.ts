import express from 'express'
import dotenv from 'dotenv'
import { writeFile } from 'fs/promises'
import path from 'path'
import multer from 'multer'
dotenv.config()
if (!process.env.API_KEY) throw new Error('\x1b[31mEnvironment variable "API_KEY" not set. This is required for authorising incoming requests.\x1b[0m')

const app = express()
const upload = multer()

app.get('/', (req, res) => {
  return res.send('Healthy')
})

/** Post an entire YAML file to be saved */
app.post('/yaml', upload.any(), async (req, res, next) => {
  // Check Authorization
  if (req.headers.authorization !== process.env.API_KEY) {
    return res.sendStatus(401)
  }
  if (!req.files) return res.status(400).json({ message: 'No files sent.' })
  if (!Array.isArray(req.files)) return res.status(400).json({ message: 'Files not returned as array.' })

  const file = req.files[0]
  if (!file) return res.status(400).json({ message: 'Data received is not a file.'})
  if (file.mimetype !== 'text/yaml') return res.status(400).json({ message: 'File sent is not a yaml file.' })

  // Save to path set in environment variables
  const filePath = process.env.WS_FILE_PATH || path.resolve('output.yml')
  await writeFile(filePath, req.files[0].buffer)
  .then(() => res.json({ filePath }))
  .catch(e => { console.log(e); next(e) })
})

app.listen(process.env.WS_PORT ?? 80, () => {
  console.log(`Server running on ${process.env.WS_PORT ?? 80}`)
})

export interface YamlRequest {
  urls: string[]
  username?: string
  password?: string
  loginUrl?: string
  pollUrl?: string
  loggedInRegex?: string
  loggedOutRegex?: string
}