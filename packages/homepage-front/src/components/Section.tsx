export type SectionProps = React.PropsWithChildren<{
  title: string
  columns: number
}>

export default function Section(props: SectionProps) {
  // FIXME: Tailwind doesn't detect properly if grid-cols is dynamic

  return <section>
    <h2 className="text-xl text-slate-50 font-bold">{props.title}</h2>
    <div className={`grid grid-cols-4`}>
      {props.children}
    </div>
  </section>
}
