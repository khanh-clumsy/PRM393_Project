import { BrowserRouter } from 'react-router-dom'
import { ToastProvider } from '../components/ui/Toast'
import { AuthProvider } from '../core/auth/AuthContext'
import AppRouter from './router'

/** Root component — router + auth session + toast */
export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <ToastProvider>
          <AppRouter />
        </ToastProvider>
      </AuthProvider>
    </BrowserRouter>
  )
}
