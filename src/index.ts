import express from 'express'
import dotenv from 'dotenv'
dotenv.config()
if (!process.env.ZAP_API_KEY) throw new Error('\x1b[31mEnvrionment variable "ZAP_API_KEY" not set. This is required for authorising incoming requests.\x1b[0m')

const app = express()


app.get('/', (req, res) => {
  return res.send('Healthy')
})

app.post('/yaml', (req, res) => {
  // Check Authorization 
  if (req.headers.authorization !== process.env.ZAP_API_KEY) {
    return res.sendStatus(401)
  }

  // Validate body

  // Generate YAML file from body

  // Save to path set in environment variables

  // Return YML file ?

  return res.sendStatus(204)
})

app.listen(80, () => {
  console.log(`\n\x1b[33mServer running at \x1b[36mhttp://localhost:80\x1b[0m`)
})