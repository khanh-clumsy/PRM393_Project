import { BrowserRouter } from 'react-router-dom'
import { AuthProvider } from '../core/auth/AuthContext'
import AppRouter from './router'

/** Root component — router + auth session */
export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <AppRouter />
      </AuthProvider>
    </BrowserRouter>
  )
}
